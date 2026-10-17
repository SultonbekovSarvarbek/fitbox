"""Kirish: telefon raqam → SMS kod → tokenlar."""

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select

from ..config import get_settings
from ..deps import CurrentUser, Session
from ..models import OtpCode, User
from ..schemas import OtpRequest, OtpRequestOut, OtpVerify, RefreshIn, TokensOut
from ..security import (
    TokenError,
    as_utc,
    decode_token,
    generate_otp,
    hash_otp,
    issue_tokens,
    normalize_phone,
    otp_matches,
)
from ..sms import SmsError, get_sms_sender

router = APIRouter(prefix="/auth", tags=["auth"])


def _phone_or_422(raw: str) -> str:
    phone = normalize_phone(raw)
    if phone is None:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "invalid_phone")
    return phone


@router.post("/otp/request", response_model=OtpRequestOut)
async def request_otp(body: OtpRequest, session: Session) -> OtpRequestOut:
    s = get_settings()
    phone = _phone_or_422(body.phone)
    now = datetime.now(timezone.utc)

    otp = await session.get(OtpCode, phone)
    if otp is not None:
        wait = s.otp_resend_seconds - (now - as_utc(otp.sent_at)).total_seconds()
        if wait > 0:
            raise HTTPException(
                status.HTTP_429_TOO_MANY_REQUESTS,
                "otp_too_soon",
                headers={"Retry-After": str(int(wait) + 1)},
            )

    code = generate_otp()
    try:
        await get_sms_sender().send(phone, f"FitBody tasdiqlash kodi: {code}")
    except SmsError:
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, "sms_failed") from None

    expires = now + timedelta(seconds=s.otp_ttl_seconds)
    if otp is None:
        session.add(
            OtpCode(
                phone=phone,
                code_hash=hash_otp(phone, code),
                expires_at=expires,
                sent_at=now,
                attempts=0,
            )
        )
    else:
        otp.code_hash = hash_otp(phone, code)
        otp.expires_at = expires
        otp.sent_at = now
        otp.attempts = 0
    await session.commit()
    return OtpRequestOut(
        phone=phone, resend_after=s.otp_resend_seconds, expires_in=s.otp_ttl_seconds
    )


@router.post("/otp/verify", response_model=TokensOut)
async def verify_otp(body: OtpVerify, session: Session) -> TokensOut:
    s = get_settings()
    phone = _phone_or_422(body.phone)
    now = datetime.now(timezone.utc)
    otp = await session.get(OtpCode, phone)

    dev_ok = s.is_dev and s.otp_dev_code is not None and body.code == s.otp_dev_code
    if not dev_ok:
        if otp is None or as_utc(otp.expires_at) < now:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "code_expired")
        if otp.attempts >= s.otp_max_attempts:
            raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, "too_many_attempts")
        if not otp_matches(phone, body.code, otp.code_hash):
            otp.attempts += 1
            await session.commit()
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "code_invalid")

    if otp is not None:
        await session.delete(otp)

    user = (await session.execute(select(User).where(User.phone == phone))).scalar_one_or_none()
    is_new = user is None
    if user is None:
        user = User(phone=phone)
        session.add(user)
    await session.commit()
    await session.refresh(user)
    return TokensOut(**issue_tokens(user.id, user.token_version), is_new_user=is_new)


@router.post("/refresh", response_model=TokensOut)
async def refresh(body: RefreshIn, session: Session) -> TokensOut:
    try:
        user_id, version = decode_token(body.refresh_token, "refresh")
    except TokenError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "invalid_refresh") from None
    user = await session.get(User, user_id)
    if user is None or user.token_version != version:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "invalid_refresh")
    return TokensOut(**issue_tokens(user.id, user.token_version))


@router.post("/logout-all", status_code=status.HTTP_204_NO_CONTENT)
async def logout_all(user: CurrentUser, session: Session) -> None:
    """Barcha qurilmalardagi tokenlarni bekor qilish."""
    user.token_version += 1
    await session.commit()
