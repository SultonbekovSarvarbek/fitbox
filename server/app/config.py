"""Sozlamalar — muhit o'zgaruvchilaridan (.env) o'qiladi."""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # dev | prod
    env: str = "dev"
    database_url: str = "postgresql+asyncpg://fitbody:fitbody@localhost:5432/fitbody"

    # JWT va OTP xeshlari uchun maxfiy kalit. Prod'da albatta uzun tasodifiy qiymat.
    secret_key: str = "dev-secret-change-me"
    access_token_minutes: int = 60 * 24
    refresh_token_days: int = 90

    # SMS kod
    otp_length: int = 6
    otp_ttl_seconds: int = 300
    otp_resend_seconds: int = 60
    otp_max_attempts: int = 5
    # Faqat dev: shu kod har doim qabul qilinadi (testchilar SMS'siz kira olishi uchun).
    otp_dev_code: str | None = None

    # SMS provayder: console | eskiz
    sms_provider: str = "console"
    eskiz_email: str | None = None
    eskiz_password: str | None = None
    eskiz_from: str = "4546"

    # Sinxronlash cheklovlari
    sync_max_batch: int = 500
    sync_max_record_bytes: int = 16_000

    @property
    def is_dev(self) -> bool:
        return self.env == "dev"


@lru_cache
def get_settings() -> Settings:
    return Settings()
