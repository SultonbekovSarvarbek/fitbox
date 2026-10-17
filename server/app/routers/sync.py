"""Sinxronlash: telefon ↔ server.

Push — telefondagi o'zgarishlar serverga (eng oxirgi o'zgartirilgani g'olib).
Pull — `since` kursoridan keyin serverda o'zgargan yozuvlar (boshqa qurilmalardan).
"""

import json
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import select

from ..config import get_settings
from ..deps import CurrentUser, Session
from ..models import Record
from ..schemas import RecordOut, SyncPullOut, SyncPush, SyncPushOut
from ..security import as_utc

router = APIRouter(prefix="/sync", tags=["sync"])

_EPOCH = datetime(1970, 1, 1, tzinfo=timezone.utc)


@router.post("", response_model=SyncPushOut)
async def push(body: SyncPush, user: CurrentUser, session: Session) -> SyncPushOut:
    s = get_settings()
    if len(body.records) > s.sync_max_batch:
        raise HTTPException(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, "batch_too_large")
    for r in body.records:
        if len(json.dumps(r.data)) > s.sync_max_record_bytes:
            raise HTTPException(
                status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, f"record_too_large:{r.id}"
            )

    ids = [r.id for r in body.records]
    existing = {
        rec.id: rec
        for rec in (await session.execute(select(Record).where(Record.id.in_(ids)))).scalars()
    }

    # Bir partiyadagi yozuvlarga ketma-ket noyob vaqt — kursor hech narsani o'tkazib yubormaydi.
    base = datetime.now(timezone.utc)
    accepted = 0
    skipped = []
    cursor = base
    for i, r in enumerate(body.records):
        ts = base + timedelta(microseconds=i)
        incoming_at = as_utc(r.updated_at)
        rec = existing.get(r.id)
        if rec is not None and (
            rec.user_id != user.id or as_utc(rec.client_updated_at) >= incoming_at
        ):
            skipped.append(r.id)
            continue
        if rec is None:
            rec = Record(id=r.id, user_id=user.id)
            session.add(rec)
            existing[r.id] = rec
        rec.kind = r.kind
        rec.data = r.data
        rec.deleted = r.deleted
        rec.client_updated_at = incoming_at
        rec.server_ts = ts
        cursor = ts
        accepted += 1
    await session.commit()
    return SyncPushOut(accepted=accepted, skipped=skipped, cursor=cursor)


@router.get("", response_model=SyncPullOut)
async def pull(
    user: CurrentUser,
    session: Session,
    since: datetime | None = None,
    limit: int = Query(default=500, ge=1, le=1000),
) -> SyncPullOut:
    since_at = as_utc(since) if since else _EPOCH
    rows = (
        await session.execute(
            select(Record)
            .where(Record.user_id == user.id, Record.server_ts > since_at)
            .order_by(Record.server_ts)
            .limit(limit + 1)
        )
    ).scalars().all()
    has_more = len(rows) > limit
    rows = rows[:limit]
    return SyncPullOut(
        records=[
            RecordOut(
                id=r.id,
                kind=r.kind,
                data=r.data,
                deleted=r.deleted,
                updated_at=as_utc(r.client_updated_at),
            )
            for r in rows
        ],
        cursor=as_utc(rows[-1].server_ts) if rows else since_at,
        has_more=has_more,
    )
