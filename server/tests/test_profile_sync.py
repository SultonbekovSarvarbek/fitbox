import uuid


async def test_me_requires_auth(client):
    assert (await client.get("/me")).status_code == 401
    r = await client.get("/me", headers={"Authorization": "Bearer nonsense"})
    assert r.status_code == 401


async def test_profile_update(client, auth):
    headers, _ = auth
    r = await client.patch(
        "/me",
        headers=headers,
        json={"full_name": "Ali", "gender": "male", "age": 30, "height_cm": 180, "weight_kg": 80},
    )
    assert r.status_code == 200
    assert r.json()["height_cm"] == 180
    # Qisman yangilash — boshqa maydonlar saqlanadi.
    r = await client.patch("/me", headers=headers, json={"weight_kg": 78})
    assert r.json()["weight_kg"] == 78
    assert r.json()["full_name"] == "Ali"
    # Chegaradan tashqari qiymat rad etiladi.
    assert (await client.patch("/me", headers=headers, json={"age": 5})).status_code == 422


def _workout(id_, at, kcal=100, deleted=False):
    return {
        "id": str(id_),
        "kind": "workout",
        "data": {"title": "Full Body", "minutes": 20, "kcal": kcal},
        "deleted": deleted,
        "updated_at": at,
    }


async def test_push_then_pull(client, auth):
    headers, _ = auth
    a, b = uuid.uuid4(), uuid.uuid4()
    r = await client.post(
        "/sync",
        headers=headers,
        json={"records": [_workout(a, "2026-10-17T10:00:00Z"), _workout(b, "2026-10-17T11:00:00Z")]},
    )
    assert r.status_code == 200
    assert r.json()["accepted"] == 2

    r = await client.get("/sync", headers=headers)
    body = r.json()
    assert {x["id"] for x in body["records"]} == {str(a), str(b)}
    cursor = body["cursor"]

    # Kursordan keyin yangi narsa yo'q.
    r = await client.get("/sync", headers=headers, params={"since": cursor})
    assert r.json()["records"] == []


async def test_last_write_wins(client, auth):
    headers, _ = auth
    a = uuid.uuid4()
    await client.post("/sync", headers=headers, json={"records": [_workout(a, "2026-10-17T12:00:00Z", 100)]})
    # Eskiroq o'zgarish — rad etiladi.
    r = await client.post("/sync", headers=headers, json={"records": [_workout(a, "2026-10-17T11:00:00Z", 50)]})
    assert r.json()["skipped"] == [str(a)]
    # Yangiroq — qabul qilinadi (o'chirish ham).
    r = await client.post(
        "/sync", headers=headers, json={"records": [_workout(a, "2026-10-17T13:00:00Z", 100, True)]}
    )
    assert r.json()["accepted"] == 1
    rec = (await client.get("/sync", headers=headers)).json()["records"][0]
    assert rec["deleted"] is True


async def test_pagination(client, auth):
    headers, _ = auth
    recs = [_workout(uuid.uuid4(), "2026-10-17T10:00:00Z") for _ in range(7)]
    await client.post("/sync", headers=headers, json={"records": recs})
    seen, since = set(), None
    for _ in range(10):
        params = {"limit": 3, **({"since": since} if since else {})}
        body = (await client.get("/sync", headers=headers, params=params)).json()
        seen |= {x["id"] for x in body["records"]}
        since = body["cursor"]
        if not body["has_more"]:
            break
    assert len(seen) == 7


async def test_users_are_isolated(client, auth, fake_sms):
    headers, _ = auth
    a = uuid.uuid4()
    await client.post("/sync", headers=headers, json={"records": [_workout(a, "2026-10-17T10:00:00Z")]})

    await client.post("/auth/otp/request", json={"phone": "+998935554433"})
    r = await client.post("/auth/otp/verify", json={"phone": "935554433", "code": fake_sms.last_code()})
    other = {"Authorization": f"Bearer {r.json()['access_token']}"}

    assert (await client.get("/sync", headers=other)).json()["records"] == []
    # Begona yozuvni ustidan yozib bo'lmaydi.
    r = await client.post("/sync", headers=other, json={"records": [_workout(a, "2030-01-01T00:00:00Z")]})
    assert r.json()["skipped"] == [str(a)]


async def test_unknown_kind_rejected(client, auth):
    headers, _ = auth
    bad = _workout(uuid.uuid4(), "2026-10-17T10:00:00Z") | {"kind": "password"}
    assert (await client.post("/sync", headers=headers, json={"records": [bad]})).status_code == 422
