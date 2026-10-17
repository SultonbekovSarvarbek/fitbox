from typing import Annotated

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from .db import get_session
from .models import User
from .security import TokenError, decode_token

Session = Annotated[AsyncSession, Depends(get_session)]


async def current_user(
    session: Session,
    authorization: Annotated[str | None, Header()] = None,
) -> User:
    unauthorized = HTTPException(
        status.HTTP_401_UNAUTHORIZED,
        detail="unauthorized",
        headers={"WWW-Authenticate": "Bearer"},
    )
    if not authorization or not authorization.lower().startswith("bearer "):
        raise unauthorized
    try:
        user_id, version = decode_token(authorization[7:], "access")
    except TokenError:
        raise unauthorized from None
    user = await session.get(User, user_id)
    if user is None or user.token_version != version:
        raise unauthorized
    return user


CurrentUser = Annotated[User, Depends(current_user)]
