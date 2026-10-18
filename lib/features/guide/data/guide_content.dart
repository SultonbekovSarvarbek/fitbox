import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/content/content_l10n.dart';

/// Qo'llanmadagi bitta bo'lim: nima uchun kerak (qisqa) va qanday ishlatiladi (qadamlar).
class GuideTopic {
  const GuideTopic({
    required this.icon,
    required this.title,
    required this.summary,
    required this.steps,
    this.route,
  });

  final IconData icon;
  final Tr title;

  /// Tanishtiruvda ko'rsatiladigan 1–2 jumla.
  final Tr summary;

  /// Qo'llanmadagi qadamlar.
  final List<Tr> steps;

  /// "Ochish" tugmasi qayerga olib boradi.
  final String? route;
}

/// Ilova maqsadi — tanishtiruvning birinchi sahifasi.
const appMission = GuideTopic(
  icon: Icons.local_fire_department_rounded,
  title: Tr(
    'Your personal coach that won\'t let you quit',
    'Sizni to\'xtatib qo\'ymaydigan shaxsiy murabbiy',
    'Личный тренер, который не даст бросить',
  ),
  summary: Tr(
    'Forkout builds a plan from your height, weight, age and goal, tells you what to do every day, counts real calories and keeps you consistent with reminders, streaks and levels.',
    'Forkout bo\'yingiz, vazningiz, yoshingiz va maqsadingizga qarab reja tuzadi, har kuni nima qilishni aytadi, real kaloriyani hisoblaydi va eslatma, seriya hamda darajalar bilan muntazam shug\'ullanishga undaydi.',
    'Forkout строит план по росту, весу, возрасту и цели, каждый день говорит, что делать, считает реальные калории и держит вас в ритме с помощью напоминаний, серий и уровней.',
  ),
  steps: [],
);

const guideTopics = <GuideTopic>[
  GuideTopic(
    icon: Icons.flag_rounded,
    title: Tr('Today\'s mission', 'Bugungi vazifa', 'Задание на сегодня'),
    summary: Tr(
      'The top card on Home shows what to do today, your streak and how much time is left.',
      'Home\'dagi eng yuqori karta bugun nima qilishni, seriyangizni va qancha vaqt qolganini ko\'rsatadi.',
      'Верхняя карточка на главной показывает задание на сегодня, серию и сколько осталось времени.',
    ),
    steps: [
      Tr(
        'Press "Start now" — the workout opens right away.',
        '"Hozir boshlash"ni bosing — mashg\'ulot darhol ochiladi.',
        'Нажмите «Начать сейчас» — тренировка откроется сразу.',
      ),
      Tr(
        'Press "Change" to choose your own mission for this weekday: bodybuilding, running or any workout.',
        '"O\'zgartirish"ni bosib, hafta kuni uchun vazifani o\'zingiz tanlang: bodybuilding, yugurish yoki istalgan mashg\'ulot.',
        'Нажмите «Изменить», чтобы выбрать своё задание на этот день: бодибилдинг, бег или любую тренировку.',
      ),
      Tr(
        'Train on every planned day to grow your streak 🔥. Rest days don\'t break it, a skipped training day does.',
        'Har rejali kunda shug\'ullaning — seriya 🔥 o\'sadi. Dam olish kuni uni uzmaydi, o\'tkazib yuborilgan mashg\'ulot kuni uzadi.',
        'Тренируйтесь в каждый запланированный день — серия 🔥 растёт. Дни отдыха её не прерывают, пропуск тренировки — прерывает.',
      ),
      Tr(
        'Tap the level bar to see your XP and achievements.',
        'Daraja chizig\'ini bossangiz — XP va yutuqlaringiz ochiladi.',
        'Нажмите на полосу уровня — откроются XP и достижения.',
      ),
    ],
  ),
  GuideTopic(
    icon: Icons.alarm_rounded,
    title: Tr(
      'Schedule and reminders',
      'Jadval va eslatmalar',
      'График и напоминания',
    ),
    summary: Tr(
      'Pick your training days and time — the phone will remind you, and once more in the evening if you haven\'t trained.',
      'Mashg\'ulot kunlari va vaqtini tanlang — telefon eslatadi, kechgacha shug\'ullanmasangiz yana bir bor eslatadi.',
      'Выберите дни и время тренировок — телефон напомнит, а вечером напомнит ещё раз, если вы не потренировались.',
    ),
    steps: [
      Tr(
        'Profile → Settings → turn on "Workout reminders" and allow notifications.',
        'Profil → Sozlamalar → "Mashg\'ulot eslatmalari"ni yoqing va bildirishnomaga ruxsat bering.',
        'Профиль → Настройки → включите «Напоминания» и разрешите уведомления.',
      ),
      Tr(
        'Tap the days you train and set the reminder time.',
        'Shug\'ullanadigan kunlaringizni belgilang va eslatma vaqtini qo\'ying.',
        'Отметьте дни тренировок и задайте время напоминания.',
      ),
      Tr(
        'Under "Mission for each day" choose what you do on each day.',
        '"Kunlik vazifalar"da har kuni nima qilishingizni tanlang.',
        'В разделе «Задания по дням» выберите, чем заниматься в каждый день.',
      ),
    ],
    route: Routes.settings,
  ),
  GuideTopic(
    icon: Icons.sports_gymnastics_rounded,
    title: Tr(
      'Workouts and AI form check',
      'Mashg\'ulotlar va AI forma tekshiruvi',
      'Тренировки и AI-проверка техники',
    ),
    summary: Tr(
      'Ready-made workouts by level with a timer, voice guide and camera form check.',
      'Darajangizga mos tayyor mashg\'ulotlar: taymer, ovozli ko\'rsatma va kamera orqali texnikani tekshirish.',
      'Готовые тренировки по уровню: таймер, голосовые подсказки и проверка техники камерой.',
    ),
    steps: [
      Tr(
        'Open "Workout", choose a level and a workout, press "Start workout".',
        '"Mashq" bo\'limini oching, daraja va mashg\'ulotni tanlang, "Mashg\'ulotni boshlash"ni bosing.',
        'Откройте «Тренировки», выберите уровень и тренировку, нажмите «Начать тренировку».',
      ),
      Tr(
        'During an exercise press "AI check" — the camera counts reps (squats, push-ups, lunges, presses, jumping jacks), times your plank and counts neck rolls.',
        "Mashq paytida «AI tekshiruv»ni bosing — kamera takrorlarni sanaydi (squat, otjimaniya, hamla, press, jumping jacks), plankada vaqtni o'lchaydi va bo'yin aylanishlarini sanaydi.",
        'Во время упражнения нажмите «AI проверка» — камера считает повторы (приседания, отжимания, выпады, жимы, джампинг-джеки), засекает планку и считает вращения шеей.',
      ),
      Tr(
        'Calories are calculated from your weight and the real time you trained.',
        'Kaloriya vazningiz va haqiqiy shug\'ullangan vaqtingizdan hisoblanadi.',
        'Калории считаются по вашему весу и реальному времени тренировки.',
      ),
      Tr(
        'Use "+" in "My plans" to build your own workout.',
        '"Mening rejalarim"da "+" bilan o\'z mashg\'ulotingizni tuzing.',
        'В «Мои планы» кнопкой «+» соберите свою тренировку.',
      ),
    ],
    route: Routes.workout,
  ),
  GuideTopic(
    icon: Icons.fitness_center_rounded,
    title: Tr('Bodybuilding', 'Bodybuilding', 'Бодибилдинг'),
    summary: Tr(
      'Gym programs with weights, sets and progressive overload, records and technique videos.',
      'Zal uchun dasturlar: og\'irlik, setlar, progressiv yuklama, rekordlar va texnika videolari.',
      'Программы для зала: веса, подходы, прогрессия нагрузки, рекорды и видео техники.',
    ),
    steps: [
      Tr(
        'Choose a program (3–6 days a week) — the next day is shown automatically.',
        'Dasturni tanlang (haftasiga 3–6 kun) — navbatdagi kun avtomatik ko\'rsatiladi.',
        'Выберите программу (3–6 дней в неделю) — следующий день показывается автоматически.',
      ),
      Tr(
        'In a session enter weight and reps for each set; the rest timer starts itself.',
        'Mashg\'ulotda har set uchun og\'irlik va takrorni kiriting; dam olish taymeri o\'zi boshlanadi.',
        'В тренировке вводите вес и повторы для каждого подхода; таймер отдыха запускается сам.',
      ),
      Tr(
        'The app suggests the next weight (+2.5 kg upper body, +5 kg legs) when you hit the top of the rep range.',
        'Takrorlar yuqori chegarasiga yetsangiz, ilova keyingi og\'irlikni taklif qiladi (yuqori tana +2.5 kg, oyoq +5 kg).',
        'Когда достигаете верхней границы повторов, приложение предлагает следующий вес (+2,5 кг верх, +5 кг ноги).',
      ),
      Tr(
        'Don\'t know the technique? Press ▶ next to the exercise or open "Technique videos".',
        'Texnikani bilmaysizmi? Mashq yonidagi ▶ ni bosing yoki "Texnika videolari"ni oching.',
        'Не знаете технику? Нажмите ▶ рядом с упражнением или откройте «Видео техники».',
      ),
    ],
    route: Routes.bodybuilding,
  ),
  GuideTopic(
    icon: Icons.directions_run_rounded,
    title: Tr('Run mode', 'Yugurish rejimi', 'Режим бега'),
    summary: Tr(
      'GPS tracks distance, pace and real calories — standing still burns nothing.',
      'GPS masofa, sur\'at va real kaloriyani hisoblaydi — joyida tursangiz kaloriya yozilmaydi.',
      'GPS считает дистанцию, темп и реальные калории — стоя на месте, калории не начисляются.',
    ),
    steps: [
      Tr(
        'Turn on location, choose walk, run or bike and press Start.',
        'Joylashuvni yoqing, yurish, yugurish yoki velosipedni tanlang va Start bosing.',
        'Включите геолокацию, выберите ходьбу, бег или велосипед и нажмите Старт.',
      ),
      Tr(
        'Hold the stop button to finish — the result is saved to statistics.',
        'Tugatish uchun to\'xtatish tugmasini bosib turing — natija statistikaga yoziladi.',
        'Чтобы закончить, удерживайте кнопку стоп — результат сохранится в статистике.',
      ),
    ],
    route: Routes.run,
  ),
  GuideTopic(
    icon: Icons.restaurant_rounded,
    title: Tr(
      'Nutrition and food scanner',
      'Ovqatlanish va ovqat skaneri',
      'Питание и сканер еды',
    ),
    summary: Tr(
      'Your personal daily calories and macros, plus a camera scanner to log what you eat.',
      'Shaxsiy kunlik kaloriya va makrolar, yeganingizni kamera bilan yozib boruvchi skaner.',
      'Личная норма калорий и БЖУ, а также сканер камерой, чтобы записывать еду.',
    ),
    steps: [
      Tr(
        'Your daily target is calculated from height, weight, age, sex, activity and goal.',
        'Kunlik maqsad bo\'y, vazn, yosh, jins, faollik va maqsadingizdan hisoblanadi.',
        'Дневная норма считается по росту, весу, возрасту, полу, активности и цели.',
      ),
      Tr(
        'Press the round "AI" button in the middle of the bottom bar, point the camera at your plate and take a photo.',
        "Pastki menyu o'rtasidagi «AI» tugmasini bosing, kamerani likopchaga qarating va suratga oling.",
        'Нажмите круглую кнопку «AI» в центре нижнего меню, наведите камеру на тарелку и сделайте фото.',
      ),
      Tr(
        'Check the portion and meal, press "Add to diary". You can also pick a photo from the gallery or enter food manually.',
        'Porsiya va ovqat vaqtini tekshirib, "Kundalikka qo\'shish"ni bosing. Galereyadan rasm tanlash yoki qo\'lda kiritish ham mumkin.',
        'Проверьте порцию и приём пищи, нажмите «Добавить в дневник». Можно выбрать фото из галереи или ввести вручную.',
      ),
      Tr(
        'Burned calories from workouts are added to your remaining budget automatically.',
        'Mashg\'ulotda yoqilgan kaloriya qolgan limitga avtomatik qo\'shiladi.',
        'Сожжённые на тренировках калории автоматически добавляются к остатку.',
      ),
    ],
    route: Routes.nutrition,
  ),
  GuideTopic(
    icon: Icons.insights_rounded,
    title: Tr('Statistics', 'Statistika', 'Статистика'),
    summary: Tr(
      'Charts of calories, minutes, activity calendar, weight and levels.',
      'Kaloriya, daqiqa, faollik kalendari, vazn va darajalar bo\'yicha grafiklar.',
      'Графики калорий, минут, календарь активности, вес и уровни.',
    ),
    steps: [
      Tr(
        'Everything you do is recorded automatically.',
        'Qilgan har ishingiz avtomatik yoziladi.',
        'Всё, что вы делаете, записывается автоматически.',
      ),
      Tr(
        'Add your weight regularly to see the trend.',
        'O\'zgarishni ko\'rish uchun vazningizni muntazam kiritib boring.',
        'Регулярно добавляйте вес, чтобы видеть динамику.',
      ),
    ],
    route: Routes.progress,
  ),
  GuideTopic(
    icon: Icons.storefront_rounded,
    title: Tr(
      'Healthy food and store',
      'Sog\'lom ovqat va do\'kon',
      'Здоровая еда и магазин',
    ),
    summary: Tr(
      'Meal delivery plans matched to your goal and a sports nutrition store.',
      'Maqsadingizga mos ovqat yetkazib berish rejalari va sport ozuqalari do\'koni.',
      'Планы доставки еды под вашу цель и магазин спортпита.',
    ),
    steps: [
      Tr(
        'Plans that fit your calorie target are shown under "Recommended for you".',
        "Kaloriya maqsadingizga mos rejalar «Sizga mos» bo'limida chiqadi.",
        'Планы под вашу норму калорий показаны в разделе «Подходит вам».',
      ),
      Tr(
        'Add products to the cart and place the order with Payme, Click or cash.',
        'Mahsulotni savatga qo\'shing va Payme, Click yoki naqd bilan buyurtma bering.',
        'Добавьте товар в корзину и оформите заказ через Payme, Click или наличными.',
      ),
    ],
    route: Routes.market,
  ),
  GuideTopic(
    icon: Icons.groups_rounded,
    title: Tr(
      'Community and devices',
      'Hamjamiyat va qurilmalar',
      'Сообщество и устройства',
    ),
    summary: Tr(
      'Challenges with other users, and a smart watch for steps, heart rate and sleep.',
      'Boshqa foydalanuvchilar bilan challenge\'lar, qadam, puls va uyqu uchun aqlli soat.',
      'Челленджи с другими пользователями и умные часы для шагов, пульса и сна.',
    ),
    steps: [
      Tr(
        'Join a challenge in "Community" and share your progress.',
        '"Hamjamiyat"da challenge\'ga qo\'shiling va natijangizni ulashing.',
        'Вступите в челлендж в «Сообществе» и делитесь прогрессом.',
      ),
      Tr(
        'Profile → Settings → Watch and devices: connect via Health Connect.',
        'Profil → Sozlamalar → Soat va qurilmalar: Health Connect orqali ulang.',
        'Профиль → Настройки → Часы и устройства: подключите через Health Connect.',
      ),
    ],
    route: Routes.community,
  ),
];
