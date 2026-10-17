"""Foydalanuvchi profili."""

from fastapi import APIRouter, status

from ..deps import CurrentUser, Session
from ..schemas import ProfileIn, ProfileOut

router = APIRouter(prefix="/me", tags=["profile"])


@router.get("", response_model=ProfileOut)
async def get_me(user: CurrentUser) -> ProfileOut:
    return ProfileOut.model_validate(user, from_attributes=True)


@router.patch("", response_model=ProfileOut)
async def update_me(body: ProfileIn, user: CurrentUser, session: Session) -> ProfileOut:
    """Faqat yuborilgan maydonlar o'zgaradi."""
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(user, field, value)
    await session.commit()
    await session.refresh(user)
    return ProfileOut.model_validate(user, from_attributes=True)


@router.delete("", status_code=status.HTTP_204_NO_CONTENT)
async def delete_me(user: CurrentUser, session: Session) -> None:
    """Akkauntni va barcha ma'lumotlarni o'chirish (App Store / Play talabi)."""
    await session.delete(user)
    await session.commit()
