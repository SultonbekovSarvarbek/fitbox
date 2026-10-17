# Fitness App — Loyiha tahlili

> Flutter · iOS + Android · Tillar: **uz / ru / en**
> Dizayn manbasi: Figma "Fitness App UI Kit" (Community)
> Holat: **1-bosqich** — arxitektura tayyor, dizayn tokenlari Figma exportini kutmoqda.

---

## 1. Texnologiyalar

| Soha | Tanlov | Izoh |
|---|---|---|
| Framework | Flutter 3.41 / Dart 3.11 | iOS + Android |
| State management | `flutter_riverpod` | test qilish oson, global DI |
| Navigatsiya | `go_router` | `StatefulShellRoute` — pastki menyu uchun |
| Tillar | `flutter_localizations` + `intl` (ARB) | `lib/l10n/app_uz.arb`, `app_ru.arb`, `app_en.arb` |
| Tarmoq | `dio` | AI server API uchun |
| Lokal saqlash | `shared_preferences` (sozlamalar), `hive`/`isar` (log, progress) | |
| Grafiklar | `fl_chart` | Progress Charts |
| Video | `video_player` / `chewie` | Workout Videos |
| Ikonlar / rasmlar | `flutter_svg` | hammasi Figma'dan SVG/PNG export |
| Kamera + Pose | `camera` + `google_mlkit_pose_detection` | AI — mashqni tekshirish |
| Ovoz | `flutter_tts` | AI — ovozli ko'rsatma |

---

## 2. Papkalar tuzilmasi (feature-first)

```
lib/
├── main.dart
├── app/
│   ├── app.dart              # MaterialApp.router, theme, locale
│   └── router.dart           # go_router — barcha marshrutlar
├── core/
│   ├── theme/
│   │   ├── app_colors.dart   # ★ RANGLAR "ROOT" — hamma rang faqat shu yerda
│   │   ├── app_text_styles.dart
│   │   ├── app_spacing.dart
│   │   └── app_theme.dart
│   ├── assets/app_icons.dart # SVG ikonlar yo'llari
│   ├── widgets/              # umumiy komponentlar (Button, Input, Card, ...)
│   ├── network/              # dio client, interceptors
│   └── utils/
├── l10n/                     # app_uz.arb, app_ru.arb, app_en.arb
└── features/
    ├── launch/  onboarding/  auth/  setup/
    ├── home/  profile/  notifications/  search/
    ├── workout/  progress/  nutrition/  community/
    ├── resources/  favorites/  support/
    └── ai/                   # pose, coach_chat, plan_generator, food_scan, tts
```

Har bir `feature/` ichida: `data/` (repository, model), `presentation/` (screens, widgets, providers).

---

## 3. Ekranlar xaritasi (Figma arxitekturasi bo'yicha)

### 1–4. Kirish oqimi
| # | Ekran | Marshrut |
|---|---|---|
| 1 | Launch (Splash) | `/` |
| 2 | On boarding | `/onboarding` |
| 3 | Login / Sign Up | `/login`, `/signup` |
| 3.1 | Forgot & Reset Password | `/forgot-password`, `/reset-password` |
| 4 | Set Up (wizard) | `/setup` |
| 4.1 | What's your gender | `/setup/gender` |
| 4.2 | How old are you | `/setup/age` |
| 4.3 | What is your weight | `/setup/weight` |
| 4.4 | What is your height | `/setup/height` |
| 4.5 | What is your goal | `/setup/goal` |
| 4.6 | Physical activity level | `/setup/activity` |
| 4.7 | Fill your profile | `/setup/profile` |

### 5. Home Page (`/home`) — bloklari
- **7. Top Menu** → 7.1 Workout · 7.2 Progress · 7.3 Nutrition · 7.4 Community
- **8.** Recommended training sessions
- **9.** Weekly Challenge
- **10.** Articles & Tips
- **6. Floating Menu** (Profile / Notifications / Search)

### 6. Floating Menu
| # | Ekran |
|---|---|
| 6.1 | Profile → 6.1.1 Edit Profile · 6.1.2 Favorites · 6.1.3 Notification · 6.1.4 Setting · 6.1.5 Help · 6.1.6 Log Out |
| 6.2 | Notifications → 6.2.1 Workout Reminders · 6.2.2 System Notifications |
| 6.3 | Search → 6.3.1 All · 6.3.2 Workout · 6.3.3 Nutrition |

### 7. Top Menu
| # | Ekran |
|---|---|
| 7.1 | Workout → 7.1.1 Preset Routines (7.1.1.1 Beginner · 7.1.1.2 Intermediate · 7.1.1.3 Advanced) · 7.1.2 Make your own routine |
| 7.2 | Progress tracking → 7.2.1 Workout Log · 7.2.2 Progress Charts |
| 7.3 | Nutrition → 7.3.1 Meal Plans · 7.3.2 Meal Ideas (Breakfast · Lunch · Dinner) |
| 7.4 | Community → 7.4.1 Discussion forum · 7.4.2 Challenges & competitions |

### 11. Bottom Navigation (4 ta tab)
| # | Tab | Ichki ekranlar |
|---|---|---|
| 11.1 | Home | → 5 |
| 11.2 | Resources | 11.2.1 Articles & Tips · 11.2.2 Workout Videos |
| 11.3 | Favorite | All · Video · Article |
| 11.4* | Support & Help | Help Center · Online Support |

\* Figma'da ikkalasi ham "11.3" deb raqamlangan — kodda 11.4 deb olindi.

---

## 4. AI qismlari

| Funksiya | Texnologiya | Qayerda | Narx | Modul |
|---|---|---|---|---|
| Kamerada mashqni tekshirish | Google ML Kit Pose | Telefonda | Bepul | `features/ai/pose` |
| Mashg'ulot rejasi tuzish | Kuchli LLM (Claude Sonnet / GPT / Gemini Pro) | Server, API | Pullik, kam chaqiriladi | `features/ai/plan_generator` |
| Ratsion va menyu tuzish | Kuchli LLM | Server | Pullik | `features/ai/meal_planner` |
| AI chat-trener | Tez va arzon LLM (Claude Haiku / Gemini Flash / GPT mini) | Server | Arzon, eng ko'p ishlatiladi | `features/ai/coach_chat` |
| Ovqat rasmidan kaloriya | Vision LLM | Server | O'rtacha | `features/ai/food_scan` |
| Ovozli ko'rsatma | Telefon TTS | Telefonda | Bepul | `features/ai/tts` |

**Qoidalar:**
- API kalitlar **hech qachon ilovada saqlanmaydi** — barcha LLM chaqiruvlari o'z serverimiz (backend proxy) orqali.
- Ilova serverga faqat `POST /ai/plan`, `/ai/meal`, `/ai/chat`, `/ai/food-scan` yuboradi; model tanlovi serverda.
- Javob tili foydalanuvchi tanlagan locale (`uz/ru/en`) bilan yuboriladi.
- Reja va menyular keshlanadi — qayta chaqiruv faqat foydalanuvchi so'raganda.
- Pose: mashq bo'yicha burchak qoidalari (masalan, squat — tizza burchagi), takrorlarni sanash, xatoda TTS orqali ogohlantirish.

---

## 5. Tillar (l10n)

- `l10n.yaml` + ARB fayllar, `flutter gen-l10n` orqali `AppLocalizations`.
- Standart til: **uz**; tanlov Settings'da, `shared_preferences`da saqlanadi.
- Kodda hech qanday matn "qattiq" yozilmaydi — faqat `context.l10n.key`.

---

## 6. Dizayn tokenlari — manba: `design/1.png`, `design/2.png`

Qora fon + neon-lime aksent, qorong'i yumaloq kartalar, katta UPPERCASE sarlavhalar.

| Token | Qiymat | Fayl |
|---|---|---|
| primary (lime) | `#DCFF2B` | `lib/core/theme/app_colors.dart` |
| background | `#0B0B0B` | 〃 |
| surface / surfaceLight / border | `#1A1A1A` / `#262626` / `#2E2E2E` | 〃 |
| textPrimary / textSecondary | `#FFFFFF` / `#8E8E93` | 〃 |
| makro: green / yellow / orange | `#34C759` / `#FFD60A` / `#FF9F0A` | 〃 |
| Shrift | Plus Jakarta Sans — ilova ichida, `assets/fonts/` (OFL) | `app_text_styles.dart` |
| Radius | 10 / 16 / 24 / 32 / pill | `app_spacing.dart` |

Umumiy widgetlar: `AppCard`, `IconChip`, `CircleIconButton`, `ImageCard`, `MediaPlaceholder`,
`PillTabs`, `WeekStrip`, `SectionTitle`, `PrimaryButton` (primary / secondary / outline).

⏳ Rasmlar: hozircha `MediaPlaceholder` (gradient + ikon). Haqiqiy fotolar `assets/images/` ga
qo'yilgach `MediaPlaceholder(asset: ...)` / `ImageCard(asset: ...)` orqali ulanadi.

## 7. Ish rejasi (bosqichma-bosqich)

1. ✅ Flutter loyihasi yaratildi (`uz.fitnessapp.fitness_app`)
2. ✅ Arxitektura va ekran xaritasi (shu fayl)
3. ⏳ Figma export → ranglar, shriftlar, ikonlar → `core/theme`
4. ✅ Paketlar, router, l10n karkasi (uz/ru/en)
5. ✅ Launch → Onboarding → Auth → Set Up (vaqtinchalik dizayn)
6. ✅ Home + Bottom Navigation (vaqtinchalik dizayn)
7. ✅ Workout (Browse, tafsilot, player, Get ready, Congratulation) · Progress · Nutrition · Community
8. ✅ Profile (Edit, Settings, Log out) · Notifications · Search · Resources · Favorites · Support (FAQ + chat)
9. 🔄 AI: ✅ TTS ovozli ko'rsatma (`features/ai/tts`) · ✅ ML Kit Pose — squat / push-up / lunge sanash (`features/ai/pose`, testlar: `test/pose_analyzer_test.dart`) · ⏳ server LLM (reja, menyu, chat, ovqat rasmi)
