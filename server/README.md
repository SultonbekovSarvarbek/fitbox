# Forkout API

FastAPI + PostgreSQL. 1-bosqich: telefon raqam orqali kirish (SMS kod), profil, ma'lumotlarni sinxronlash.

## Ishga tushirish (mahalliy)

```bash
cd server
cp .env.example .env        # SECRET_KEY'ni o'zgartiring
docker compose up -d --build
```

- API: http://localhost:8000
- Hujjat (faqat `ENV=dev`): http://localhost:8000/docs
- Emulator'dan: `http://10.0.2.2:8000`, telefondan: `http://<kompyuter IP>:8000` (bir Wi-Fi'da)

Dev rejimida SMS jo'natilmaydi — kod server jurnalida chiqadi:

```bash
docker compose logs -f api | grep SMS
```

`OTP_DEV_CODE` berilgan bo'lsa (masalan `111111`), testchilar SMS'siz shu kod bilan kiradi. **Prod'da o'chiring.**

## Testlar

```bash
python -m venv .venv
.venv/Scripts/pip install -r requirements-dev.txt   # Linux/Mac: .venv/bin/pip
.venv/Scripts/python -m pytest
```

Testlar Postgres'siz ishlaydi (vaqtinchalik SQLite).

## API

| Metod | Yo'l | Vazifa |
|---|---|---|
| POST | `/auth/otp/request` | `{phone}` → SMS kod (60 s da bir marta, 5 daqiqa amal qiladi) |
| POST | `/auth/otp/verify` | `{phone, code}` → `access_token`, `refresh_token`, `is_new_user` |
| POST | `/auth/refresh` | `{refresh_token}` → yangi tokenlar |
| POST | `/auth/logout-all` | Barcha qurilmalardan chiqish |
| GET / PATCH | `/me` | Profil (bo'y, vazn, yosh, jins, maqsad…) |
| DELETE | `/me` | Akkaunt va barcha ma'lumotni o'chirish |
| POST | `/sync` | Telefondagi o'zgarishlar → server |
| GET | `/sync?since=<cursor>` | Serverdagi o'zgarishlar → telefon |

### Sinxronlash qoidasi

Har yozuvning (`workout`, `weight`, `food`, `bb_session`) telefon yaratgan UUID'si bor.
Ikki qurilmada bir yozuv o'zgarsa — `updated_at` eng yangisi g'olib. O'chirish ham
yozuv sifatida yuboriladi (`deleted: true`), shunda boshqa qurilmalar ham o'chiradi.

## Baza o'zgarishlari (migratsiya)

Model o'zgargach:

```bash
docker compose up -d db
DATABASE_URL=postgresql+asyncpg://fitbody:fitbody@localhost:5433/fitbody \
  .venv/Scripts/alembic revision --autogenerate -m "nima o'zgardi"
```

API konteyneri ishga tushganda `alembic upgrade head` o'zi bajariladi.

## Prod uchun eslatmalar

- Server O'zbekistonda joylashishi kerak (shaxsiy ma'lumotlar qonuni).
- `ENV=prod`, uzun tasodifiy `SECRET_KEY`, `OTP_DEV_CODE` yo'q, `SMS_PROVIDER=eskiz`.
- HTTPS (masalan Caddy yoki Nginx orqali) — tokenlar ochiq tarmoqda yurmasligi kerak.
- Eskiz'da SMS matni shabloni oldindan tasdiqlanishi kerak.
