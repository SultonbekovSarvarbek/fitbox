"""SMS jo'natish. Dev'da — konsolga, prod'da — Eskiz.uz orqali."""

import logging
import time

import httpx

from .config import get_settings

log = logging.getLogger("fitbody.sms")


class SmsError(Exception):
    pass


class SmsSender:
    async def send(self, phone: str, text: str) -> None:  # pragma: no cover
        raise NotImplementedError


class ConsoleSms(SmsSender):
    """Ishlab chiqish uchun: SMS jo'natilmaydi, server jurnaliga yoziladi."""

    async def send(self, phone: str, text: str) -> None:
        log.warning("SMS → %s: %s", phone, text)


class EskizSms(SmsSender):
    """Eskiz.uz (notify.eskiz.uz). Token 30 kun amal qiladi — keshlanadi.

    Diqqat: Eskiz'da SMS matni shabloni oldindan tasdiqlangan bo'lishi kerak.
    TODO: haqiqiy akkaunt bilan sinab ko'rish.
    """

    _base = "https://notify.eskiz.uz/api"

    def __init__(self, email: str, password: str, sender: str) -> None:
        self._email = email
        self._password = password
        self._sender = sender
        self._token: str | None = None
        self._token_at = 0.0

    async def _login(self, client: httpx.AsyncClient) -> str:
        if self._token and time.time() - self._token_at < 25 * 24 * 3600:
            return self._token
        r = await client.post(
            f"{self._base}/auth/login",
            data={"email": self._email, "password": self._password},
        )
        if r.status_code != 200:
            raise SmsError(f"Eskiz login: {r.status_code}")
        self._token = r.json()["data"]["token"]
        self._token_at = time.time()
        return self._token

    async def send(self, phone: str, text: str) -> None:
        async with httpx.AsyncClient(timeout=15) as client:
            token = await self._login(client)
            r = await client.post(
                f"{self._base}/message/sms/send",
                headers={"Authorization": f"Bearer {token}"},
                data={
                    "mobile_phone": phone.lstrip("+"),
                    "message": text,
                    "from": self._sender,
                },
            )
            if r.status_code != 200:
                raise SmsError(f"Eskiz send: {r.status_code} {r.text[:200]}")


_sender: SmsSender | None = None


def get_sms_sender() -> SmsSender:
    global _sender
    if _sender is None:
        s = get_settings()
        if s.sms_provider == "eskiz":
            if not (s.eskiz_email and s.eskiz_password):
                raise RuntimeError("ESKIZ_EMAIL / ESKIZ_PASSWORD berilmagan")
            _sender = EskizSms(s.eskiz_email, s.eskiz_password, s.eskiz_from)
        else:
            _sender = ConsoleSms()
    return _sender
