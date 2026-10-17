"""Ma'lumotlar bazasi jadvallari."""

import uuid
from datetime import datetime, timezone

from sqlalchemy import JSON, Boolean, DateTime, ForeignKey, Index, Integer, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from .db import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    # +998XXXXXXXXX ko'rinishida (normallashtirilgan).
    phone: Mapped[str] = mapped_column(String(16), unique=True, index=True)

    # Profil (ilovadagi Setup bilan bir xil).
    full_name: Mapped[str | None] = mapped_column(String(120))
    nickname: Mapped[str | None] = mapped_column(String(60))
    gender: Mapped[str | None] = mapped_column(String(16))
    age: Mapped[int | None] = mapped_column(Integer)
    height_cm: Mapped[int | None] = mapped_column(Integer)
    weight_kg: Mapped[int | None] = mapped_column(Integer)
    goal: Mapped[str | None] = mapped_column(String(32))
    activity_level: Mapped[str | None] = mapped_column(String(32))
    locale: Mapped[str | None] = mapped_column(String(8))

    # Oshirilsa — barcha eski tokenlar bekor bo'ladi ("hamma qurilmalardan chiqish").
    token_version: Mapped[int] = mapped_column(Integer, default=0)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, onupdate=utcnow
    )


class OtpCode(Base):
    """Telefon raqamga yuborilgan oxirgi kod (xeshlangan holda)."""

    __tablename__ = "otp_codes"

    phone: Mapped[str] = mapped_column(String(16), primary_key=True)
    code_hash: Mapped[str] = mapped_column(String(128))
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    sent_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    attempts: Mapped[int] = mapped_column(Integer, default=0)


class Record(Base):
    """Sinxronlanadigan yozuv: mashg'ulot, vazn, ovqat, bodybuilding sessiyasi.

    `id` — telefonning o'zi yaratgan UUID (oflayn ishlash uchun).
    `client_updated_at` — oxirgi o'zgarish vaqti (eng yangisi g'olib).
    `server_ts` — serverda yozilgan vaqt; sinxronlash kursori shu bo'yicha.
    """

    __tablename__ = "records"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True)
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    kind: Mapped[str] = mapped_column(String(24))
    data: Mapped[dict] = mapped_column(JSON)
    deleted: Mapped[bool] = mapped_column(Boolean, default=False)
    client_updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    server_ts: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    __table_args__ = (Index("ix_records_user_server_ts", "user_id", "server_ts"),)
