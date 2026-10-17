from app.security import normalize_phone


def test_normalize_phone():
    assert normalize_phone("+998 90 123-45-67") == "+998901234567"
    assert normalize_phone("901234567") == "+998901234567"
    assert normalize_phone("998901234567") == "+998901234567"
    assert normalize_phone("12345") is None
    assert normalize_phone("+7 999 123 45 67") is None


async def test_otp_flow_creates_user(client, fake_sms):
    r = await client.post("/auth/otp/request", json={"phone": "+998901234567"})
    assert r.status_code == 200
    assert fake_sms.sent[0][0] == "+998901234567"

    r = await client.post(
        "/auth/otp/verify",
        json={"phone": "+998901234567", "code": fake_sms.last_code()},
    )
    assert r.status_code == 200
    body = r.json()
    assert body["is_new_user"] is True
    assert body["access_token"] and body["refresh_token"]

    # Kod bir martalik.
    r = await client.post(
        "/auth/otp/verify",
        json={"phone": "+998901234567", "code": fake_sms.last_code()},
    )
    assert r.status_code == 400


async def test_wrong_code_and_attempt_limit(client, fake_sms):
    await client.post("/auth/otp/request", json={"phone": "901234567"})
    wrong = "000000" if fake_sms.last_code() != "000000" else "111111"
    for _ in range(5):
        r = await client.post("/auth/otp/verify", json={"phone": "901234567", "code": wrong})
        assert r.status_code == 400
        assert r.json()["detail"] == "code_invalid"
    # 5 ta xatodan keyin — to'g'ri kod ham qabul qilinmaydi.
    r = await client.post(
        "/auth/otp/verify", json={"phone": "901234567", "code": fake_sms.last_code()}
    )
    assert r.status_code == 429


async def test_resend_cooldown(client, fake_sms):
    assert (await client.post("/auth/otp/request", json={"phone": "901234567"})).status_code == 200
    r = await client.post("/auth/otp/request", json={"phone": "901234567"})
    assert r.status_code == 429
    assert int(r.headers["Retry-After"]) > 0


async def test_invalid_phone(client, fake_sms):
    r = await client.post("/auth/otp/request", json={"phone": "12"})
    assert r.status_code == 422


async def test_second_login_is_not_new(client, fake_sms, auth, monkeypatch):
    from app.config import get_settings

    monkeypatch.setattr(get_settings(), "otp_resend_seconds", 0)
    await client.post("/auth/otp/request", json={"phone": "901234567"})
    r = await client.post(
        "/auth/otp/verify", json={"phone": "901234567", "code": fake_sms.last_code()}
    )
    assert r.json()["is_new_user"] is False


async def test_refresh_and_logout_all(client, auth):
    headers, tokens = auth
    r = await client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r.status_code == 200
    # Access token refresh o'rnida ishlamaydi.
    r = await client.post("/auth/refresh", json={"refresh_token": tokens["access_token"]})
    assert r.status_code == 401

    assert (await client.post("/auth/logout-all", headers=headers)).status_code == 204
    assert (await client.get("/me", headers=headers)).status_code == 401
    r = await client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert r.status_code == 401


async def test_dev_code(client, monkeypatch):
    from app.config import get_settings

    monkeypatch.setattr(get_settings(), "otp_dev_code", "777777")
    r = await client.post("/auth/otp/verify", json={"phone": "901112233", "code": "777777"})
    assert r.status_code == 200
    monkeypatch.setattr(get_settings(), "env", "prod")
    r = await client.post("/auth/otp/verify", json={"phone": "901112233", "code": "777777"})
    assert r.status_code == 400
