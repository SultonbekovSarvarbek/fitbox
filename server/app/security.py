"""Telefon raqam, OTP xeshi va JWT tokenlar."""

import hashlib
import hmac
import re
import secrets
import uuid
from datetime import datetime, timedelta, timezone

import jwt

from .config import get_settings

_ALGO = "HS256"


def normalize_phone(raw: str) -> str | None:
    """O'zbekiston raqami → +998XXXXXXXXX. Noto'g'ri bo'lsa None.

    Qabul qilinadi: "+998 90 123 45 67", "998901234567", "901234567".
    """
    digits = re.sub(r"\D", "", raw)
    if len(digits) == 9:
        digits = "998" + digits
    if len(digits) != 12 or not digits.startswith("998"):
        return None
    return "+" + digits


def generate_otp() -> str:
    n = get_settings().otp_length
    return "".join(secrets.choice("0123456789") for _ in range(n))


def hash_otp(phone: str, code: str) -> str:
    key = get_settings().secret_key.encode()
    return hmac.new(key, f"{phone}:{code}".encode(), hashlib.sha256).hexdigest()


def otp_matches(phone: str, code: str, code_hash: str) -> bool:
    return hmac.compare_digest(hash_otp(phone, code), code_hash)


def as_utc(dt: datetime) -> datetime:
    """SQLite vaqt zonasisiz qaytaradi — solishtirish uchun UTC deb belgilaymiz."""
    return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)


def _encode(user_id: uuid.UUID, version: int, kind: str, ttl: timedelta) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": str(user_id),
        "ver": version,
        "typ": kind,
        "iat": int(now.timestamp()),
        "exp": int((now + ttl).timestamp()),
    }
    return jwt.encode(payload, get_settings().secret_key, algorithm=_ALGO)


def issue_tokens(user_id: uuid.UUID, version: int) -> dict[str, str | int]:
    s = get_settings()
    return {
        "access_token": _encode(
            user_id, version, "access", timedelta(minutes=s.access_token_minutes)
        ),
        "refresh_token": _encode(
            user_id, version, "refresh", timedelta(days=s.refresh_token_days)
        ),
        "token_type": "bearer",
        "expires_in": s.access_token_minutes * 60,
    }


class TokenError(Exception):
    pass


def decode_token(token: str, expected: str) -> tuple[uuid.UUID, int]:
    try:
        payload = jwt.decode(token, get_settings().secret_key, algorithms=[_ALGO])
    except jwt.PyJWTError as e:
        raise TokenError(str(e)) from e
    if payload.get("typ") != expected:
        raise TokenError("wrong token type")
    try:
        return uuid.UUID(payload["sub"]), int(payload["ver"])
    except (KeyError, ValueError) as e:
        raise TokenError("bad payload") from e
