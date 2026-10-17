import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

RecordKind = Literal["workout", "weight", "food", "bb_session"]


class OtpRequest(BaseModel):
    phone: str = Field(max_length=32)


class OtpRequestOut(BaseModel):
    phone: str
    resend_after: int
    expires_in: int


class OtpVerify(BaseModel):
    phone: str = Field(max_length=32)
    code: str = Field(min_length=4, max_length=8)


class RefreshIn(BaseModel):
    refresh_token: str


class TokensOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str
    expires_in: int
    is_new_user: bool = False


class ProfileIn(BaseModel):
    full_name: str | None = Field(default=None, max_length=120)
    nickname: str | None = Field(default=None, max_length=60)
    gender: Literal["male", "female"] | None = None
    age: int | None = Field(default=None, ge=10, le=100)
    height_cm: int | None = Field(default=None, ge=100, le=250)
    weight_kg: int | None = Field(default=None, ge=25, le=300)
    goal: str | None = Field(default=None, max_length=32)
    activity_level: str | None = Field(default=None, max_length=32)
    locale: Literal["uz", "ru", "en"] | None = None


class ProfileOut(ProfileIn):
    id: uuid.UUID
    phone: str
    created_at: datetime


class RecordIn(BaseModel):
    id: uuid.UUID
    kind: RecordKind
    data: dict
    deleted: bool = False
    updated_at: datetime


class RecordOut(BaseModel):
    id: uuid.UUID
    kind: RecordKind
    data: dict
    deleted: bool
    updated_at: datetime


class SyncPush(BaseModel):
    records: list[RecordIn]


class SyncPushOut(BaseModel):
    accepted: int
    # Serverdagisi yangiroq bo'lgani uchun qabul qilinmaganlar.
    skipped: list[uuid.UUID]
    cursor: datetime


class SyncPullOut(BaseModel):
    records: list[RecordOut]
    cursor: datetime
    has_more: bool
