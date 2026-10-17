# FitBody

Flutter fitness ilovasi (Android / iOS · uz / ru / en): mashg'ulotlar, bodybuilding,
yugurish, ovqatlanish, AI kamera (ML Kit pose), motivatsiya va eslatmalar.

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
