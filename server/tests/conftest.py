import os
import tempfile

# Testlar Postgres'siz — vaqtinchalik SQLite fayl. Ilova import qilinishidan OLDIN.
_db = os.path.join(tempfile.mkdtemp(), "test.db")
os.environ["DATABASE_URL"] = f"sqlite+aiosqlite:///{_db}"
os.environ["ENV"] = "dev"
os.environ["SECRET_KEY"] = "test-secret"
os.environ.pop("OTP_DEV_CODE", None)

import pytest  # noqa: E402
from httpx import ASGITransport, AsyncClient  # noqa: E402

from app import sms  # noqa: E402
from app.config import get_settings  # noqa: E402
from app.db import Base, engine  # noqa: E402
from app.main import app  # noqa: E402


class FakeSms(sms.SmsSender):
    def __init__(self) -> None:
        self.sent: list[tuple[str, str]] = []

    async def send(self, phone: str, text: str) -> None:
        self.sent.append((phone, text))

    def last_code(self) -> str:
        return self.sent[-1][1].split(":")[-1].strip()


@pytest.fixture
async def client():
    get_settings.cache_clear()
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


@pytest.fixture
def fake_sms(monkeypatch):
    fake = FakeSms()
    monkeypatch.setattr(sms, "_sender", fake)
    return fake


@pytest.fixture
async def auth(client, fake_sms):
    """Kirgan foydalanuvchi: (sarlavhalar, tokenlar)."""
    await client.post("/auth/otp/request", json={"phone": "+998 90 123 45 67"})
    r = await client.post(
        "/auth/otp/verify", json={"phone": "901234567", "code": fake_sms.last_code()}
    )
    tokens = r.json()
    return {"Authorization": f"Bearer {tokens['access_token']}"}, tokens
