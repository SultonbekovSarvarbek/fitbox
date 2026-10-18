# Forkout

Flutter ilovasi (Android / iOS · uz / ru / en): sport ovqatlanish do'koni, bitta oshxonadan
kuniga uch mahal yetkaziladigan ovqat obunasi va ovqatlanish hamda sport bo'yicha yangiliklar.

- **Do'kon**: protein, kreatin va boshqalar; mahsulot sahifasida qo'llanilishi, tarkibi, qarshi ko'rsatmalar.
- **Obuna**: Forkout Kitchen ratsionlari, 1 yoki 3 oy, kuryer ertalab / tushlik / kechqurun; to'lov oqimi (demo).
- **Anketa va tavsiya**: vazn, maqsad, haftalik mashg'ulot va jins bo'yicha shaxsiy tanlov.
- **Akkaunt**: telefon + SMS kod (demo kod), profil, obunani to'xtatish / bekor qilish, akkauntni o'chirish.
- **Yangiliklar**: ovqatlanish, sport, qo'shimchalar, retseptlar; erkaklar va ayollar uchun alohida.

Mashg'ulot bo'limlari (workout, bodybuilding, yugurish) kodda qolgan, lekin menyudan yashirilgan.
Kamera orqali tekshirish (ML Kit) olib tashlangan: eski kod `lib/features/ai/pose/pose_check_screen.dart.mlkit`.
Demo: to'lov, SMS, katalog va yangiliklar namunaviy; admin panel va serverga ulanish hali yo'q.

## Papkalar

| Papka | Nima |
|---|---|
| `lib/` | Ilova kodi (`features/` — bo'limlar, `core/` — umumiy vidjet va tema) |
| `test/` | Unit testlar (`flutter test`) |
| `assets/` | Rasmlar, shriftlar, ikonlar |
| `design/` | Dizayn manbasi (1.png, 2.png) |
| `server/` | Backend: FastAPI + PostgreSQL (`server/README.md`) |
| `docs/` | Loyiha tahlili |
| `release/symbols/` | Chiqarilgan APK'ning debug belgilari — saqlang (pastga qarang) |

## Build

```bash
flutter pub get
flutter gen-l10n
flutter test

# Testchilar uchun APK (telefon turiga qarab alohida, kichik hajm)
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=release/symbols

# Play Market uchun
flutter build appbundle --release --obfuscate --split-debug-info=release/symbols
```

`app-arm64-v8a-release.apk` — hozirgi telefonlar, `app-armeabi-v7a-release.apk` — eski 32-bit.

Kod obfuskatsiya qilingan, shuning uchun xato izini (stack trace) o'qish uchun
o'sha build'ning belgilari kerak:

```bash
flutter symbolize -i crash.txt -d release/symbols/app.android-arm64.symbols
```

`build/` va `.dart_tool/` — vaqtinchalik, `flutter clean` bilan o'chirsa bo'ladi.
