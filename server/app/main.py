import logging

from fastapi import FastAPI

from .config import get_settings
from .routers import auth, me, sync

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")

app = FastAPI(
    title="FitBody API",
    version="0.1.0",
    # Hujjat sahifasi faqat dev'da ochiq.
    docs_url="/docs" if get_settings().is_dev else None,
    redoc_url=None,
)

app.include_router(auth.router)
app.include_router(me.router)
app.include_router(sync.router)


@app.get("/health", tags=["system"])
async def health() -> dict[str, str]:
    return {"status": "ok"}
