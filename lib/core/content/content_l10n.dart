import 'package:flutter/widgets.dart';

/// Kontent (mashq, mashg'ulot, taom, maqola, post…) tarjimalari — ID bo'yicha.
///
/// Modellarda asl (inglizcha) matn va ID saqlanadi — MET hisobi, AI pose, rasm yo'llari
/// shunga tayanadi. Ekranda esa shu katalogdan tanlangan tildagi matn olinadi.
/// Katalogda yo'q matn (foydalanuvchi o'zi yozgan post, o'zi tuzgan reja) — o'zgarmay chiqadi.
/// TODO(backend/cms): kontent serverdan har bir tilda keladi.
class Tr {
  const Tr(this.en, this.uz, this.ru);

  final String en;
  final String uz;
  final String ru;

  String forCode(String code) => switch (code) {
    'uz' => uz,
    'ru' => ru,
    _ => en,
  };

  String of(BuildContext context) =>
      forCode(Localizations.localeOf(context).languageCode);
}

/// Inglizcha kalit → tarjima. Topilmasa — kalitning o'zi.
String trKey(BuildContext context, Map<String, Tr> table, String key) =>
    table[key]?.of(context) ?? key;

String trKeyCode(String code, Map<String, Tr> table, String key) =>
    table[key]?.forCode(code) ?? key;

// ---------------------------------------------------------------------------
// Mashqlar (kalit — inglizcha nom)
// ---------------------------------------------------------------------------

const exerciseNames = <String, Tr>{
  'Jumping Jacks': Tr(
    'Jumping Jacks',
    "Sakrab qo'l-oyoq ochish",
    'Прыжки «Джек»',
  ),
  'Bodyweight Squat': Tr('Bodyweight Squat', "O'tirib-turish", 'Приседания'),
  'Knee Push Ups': Tr(
    'Knee Push Ups',
    "Tizzada otjimaniya",
    'Отжимания с колен',
  ),
  'Plank': Tr('Plank', 'Planka', 'Планка'),
  'Neck Rolls': Tr('Neck Rolls', 'Bo\'yinni aylantirish', 'Вращения шеей'),
  'Cat-Cow': Tr('Cat-Cow', 'Mushuk-sigir', 'Кошка-корова'),
  'Hamstring Stretch': Tr(
    'Hamstring Stretch',
    'Son orqasini cho\'zish',
    'Растяжка задней поверхности бедра',
  ),
  'Push Ups': Tr('Push Ups', 'Otjimaniya', 'Отжимания'),
  'Dumbbell Rows': Tr(
    'Dumbbell Rows',
    'Gantelni belga tortish',
    'Тяга гантели в наклоне',
  ),
  'Shoulder Press': Tr('Shoulder Press', 'Yelka uchun press', 'Жим на плечи'),
  'Tricep Dips': Tr(
    'Tricep Dips',
    'Triseps uchun otjimaniya',
    'Обратные отжимания',
  ),
  'Goblet Squat': Tr(
    'Goblet Squat',
    'Gantel bilan o\'tirib-turish',
    'Гоблет-приседания',
  ),
  'Lunges': Tr('Lunges', 'Hamla (lunj)', 'Выпады'),
  'Glute Bridge': Tr('Glute Bridge', "Dumba ko'prigi", 'Ягодичный мостик'),
  'Calf Raises': Tr(
    'Calf Raises',
    "Oyoq uchida ko'tarilish",
    'Подъёмы на носки',
  ),
  'Burpees': Tr('Burpees', 'Berpi', 'Бёрпи'),
  'Jump Squats': Tr(
    'Jump Squats',
    "Sakrab o'tirib-turish",
    'Приседания с прыжком',
  ),
  'Mountain Climbers': Tr('Mountain Climbers', "Alpinist", 'Скалолаз'),
  'Plank With Hip Twist': Tr(
    'Plank With Hip Twist',
    'Son burab planka',
    'Планка со скручиванием',
  ),
  'Deadlift': Tr('Deadlift', 'Stanovaya tortish', 'Становая тяга'),
  'Bench Press': Tr('Bench Press', 'Skameykada jim', 'Жим лёжа'),
  'Pull Ups': Tr('Pull Ups', 'Turnikda tortilish', 'Подтягивания'),
  'Overhead Press': Tr('Overhead Press', 'Bosh ustiga jim', 'Жим над головой'),
  'Crunches': Tr('Crunches', 'Qorin pressi', 'Скручивания'),
};

// ---------------------------------------------------------------------------
// Mashg'ulotlar (kalit — routine id)
// ---------------------------------------------------------------------------

const routineTitles = <String, Tr>{
  'b1': Tr('Full Body Starter', 'Butun tana: boshlang\'ich', 'Всё тело: старт'),
  'b2': Tr('Morning Stretching', 'Ertalabki cho\'zilish', 'Утренняя растяжка'),
  'i1': Tr('Upper Body Power', 'Yuqori tana kuchi', 'Сила верха тела'),
  'i2': Tr('Leg Day', 'Oyoqlar kuni', 'День ног'),
  'a1': Tr('HIIT Burner', 'HIIT yondirgich', 'HIIT-жиросжигание'),
  'a2': Tr('Strength Complex', 'Kuch kompleksi', 'Силовой комплекс'),
};

// ---------------------------------------------------------------------------
// Taomlar (kalit — meal id; masalliqlar — inglizcha matn)
// ---------------------------------------------------------------------------

const mealTitles = <String, Tr>{
  'm1': Tr(
    'Oatmeal With Berries',
    'Rezavorli suli bo\'tqasi',
    'Овсянка с ягодами',
  ),
  'm2': Tr(
    'Egg & Avocado Toast',
    'Tuxum va avokadoli tost',
    'Тост с яйцом и авокадо',
  ),
  'm3': Tr(
    'Greek Yogurt Bowl',
    'Grek yogurti bilan kosa',
    'Боул с греческим йогуртом',
  ),
  'm4': Tr('Chicken Rice Bowl', 'Tovuq va guruch', 'Курица с рисом'),
  'm5': Tr('Tuna Salad', 'Tunets salati', 'Салат с тунцом'),
  'm6': Tr('Salmon & Vegetables', 'Losos va sabzavotlar', 'Лосось с овощами'),
  'm7': Tr('Turkey Stir Fry', 'Kurka go\'shti qovurmasi', 'Индейка стир-фрай'),
};

const ingredients = <String, Tr>{
  'Oats 60 g': Tr('Oats 60 g', 'Suli 60 g', 'Овсяные хлопья 60 г'),
  'Milk 200 ml': Tr('Milk 200 ml', 'Sut 200 ml', 'Молоко 200 мл'),
  'Blueberries 50 g': Tr(
    'Blueberries 50 g',
    "Ko'k rezavor 50 g",
    'Черника 50 г',
  ),
  'Honey 1 tsp': Tr('Honey 1 tsp', 'Asal 1 choy qoshiq', 'Мёд 1 ч. л.'),
  'Whole grain bread 2 slices': Tr(
    'Whole grain bread 2 slices',
    "Bug'doy noni 2 bo'lak",
    'Цельнозерновой хлеб 2 ломтика',
  ),
  'Eggs 2': Tr('Eggs 2', 'Tuxum 2 dona', 'Яйца 2 шт.'),
  'Avocado ½': Tr('Avocado ½', 'Avokado ½', 'Авокадо ½'),
  'Salt, pepper': Tr('Salt, pepper', "Tuz, qalampir", 'Соль, перец'),
  'Greek yogurt 200 g': Tr(
    'Greek yogurt 200 g',
    'Grek yogurti 200 g',
    'Греческий йогурт 200 г',
  ),
  'Granola 30 g': Tr('Granola 30 g', 'Granola 30 g', 'Гранола 30 г'),
  'Banana ½': Tr('Banana ½', 'Banan ½', 'Банан ½'),
  'Chicken breast 150 g': Tr(
    'Chicken breast 150 g',
    "Tovuq ko'kragi 150 g",
    'Куриная грудка 150 г',
  ),
  'Rice 80 g': Tr('Rice 80 g', 'Guruch 80 g', 'Рис 80 г'),
  'Broccoli 100 g': Tr('Broccoli 100 g', 'Brokkoli 100 g', 'Брокколи 100 г'),
  'Soy sauce': Tr('Soy sauce', 'Soya sousi', 'Соевый соус'),
  'Tuna 120 g': Tr('Tuna 120 g', 'Tunets 120 g', 'Тунец 120 г'),
  'Lettuce': Tr('Lettuce', 'Salat bargi', 'Листья салата'),
  'Cherry tomatoes': Tr('Cherry tomatoes', 'Cherri pomidor', 'Помидоры черри'),
  'Olive oil 1 tbsp': Tr(
    'Olive oil 1 tbsp',
    "Zaytun moyi 1 osh qoshiq",
    'Оливковое масло 1 ст. л.',
  ),
  'Salmon 150 g': Tr('Salmon 150 g', 'Losos 150 g', 'Лосось 150 г'),
  'Zucchini': Tr('Zucchini', 'Qovoqcha', 'Кабачок'),
  'Bell pepper': Tr('Bell pepper', 'Bolgar qalampiri', 'Болгарский перец'),
  'Lemon': Tr('Lemon', 'Limon', 'Лимон'),
  'Turkey 150 g': Tr('Turkey 150 g', "Kurka go'shti 150 g", 'Индейка 150 г'),
  'Mixed vegetables 200 g': Tr(
    'Mixed vegetables 200 g',
    'Aralash sabzavotlar 200 g',
    'Овощная смесь 200 г',
  ),
  'Garlic': Tr('Garlic', 'Sarimsoq', 'Чеснок'),
};

// ---------------------------------------------------------------------------
// Maqola / videolar (kalit — resource id)
// ---------------------------------------------------------------------------

const resourceTitles = <String, Tr>{
  'a1': Tr(
    'Supplement Guide: what you really need',
    "Qo'shimchalar: sizga aslida nima kerak",
    'Добавки: что действительно нужно',
  ),
  'a2': Tr(
    '15 Quick & Effective Daily Routines',
    '15 ta tez va samarali kundalik mashg\'ulot',
    '15 быстрых и эффективных ежедневных тренировок',
  ),
  'a3': Tr(
    'Why sleep is your best recovery tool',
    'Nega uyqu — eng yaxshi tiklanish vositasi',
    'Почему сон — лучшее средство восстановления',
  ),
  'v1': Tr(
    'Perfect Push Up Technique',
    'Otjimaniyaning to\'g\'ri texnikasi',
    'Идеальная техника отжиманий',
  ),
  'v2': Tr(
    'Full Body Morning Stretch',
    'Butun tana uchun ertalabki cho\'zilish',
    'Утренняя растяжка всего тела',
  ),
  'v3': Tr(
    'Home HIIT — No Equipment',
    'Uyda HIIT — jihozsiz',
    'HIIT дома — без инвентаря',
  ),
  'v4': Tr(
    'Core Burnout in 15 Minutes',
    '15 daqiqada qorin mushaklari',
    'Пресс за 15 минут',
  ),
};

const resourceCategories = <String, Tr>{
  'Nutrition': Tr('Nutrition', 'Ovqatlanish', 'Питание'),
  'Training': Tr('Training', "Mashg'ulot", 'Тренировки'),
  'Recovery': Tr('Recovery', 'Tiklanish', 'Восстановление'),
  'Strength': Tr('Strength', 'Kuch', 'Сила'),
  'Mobility': Tr('Mobility', 'Harakatchanlik', 'Мобильность'),
  'HIIT': Tr('HIIT', 'HIIT', 'HIIT'),
  'Core': Tr('Core', 'Qorin mushaklari', 'Кор'),
};

const resourceBodies = <String, List<Tr>>{
  'a1': [
    Tr(
      'Most people can cover their needs with whole foods. Supplements are there to fill gaps, not to replace meals.',
      "Ko'pchilik ehtiyojini oddiy, tabiiy ovqat bilan qoplay oladi. Qo'shimchalar ovqat o'rnini bosish uchun emas, kamchilikni to'ldirish uchun.",
      'Большинство людей могут закрыть свои потребности обычной едой. Добавки нужны, чтобы восполнить пробелы, а не заменить питание.',
    ),
    Tr(
      'Protein powder is convenient if you struggle to reach your daily protein target. Creatine monohydrate is the most researched supplement for strength.',
      "Kunlik oqsil me'yoriga yetish qiyin bo'lsa, protein kukuni qulay. Kreatin monogidrat — kuch uchun eng ko'p o'rganilgan qo'shimcha.",
      'Протеин удобен, если сложно добрать дневную норму белка. Креатин моногидрат — самая изученная добавка для силы.',
    ),
    Tr(
      'Vitamin D is worth checking with your doctor, especially in winter. Everything else — ask whether it solves a real problem for you.',
      "D vitamini darajasini, ayniqsa qishda, shifokor bilan tekshirib ko'ring. Qolgan hammasi uchun o'zingizdan so'rang: bu haqiqiy muammoni hal qiladimi?",
      'Уровень витамина D стоит проверить у врача, особенно зимой. Про всё остальное спросите себя: решает ли это реальную проблему?',
    ),
  ],
  'a2': [
    Tr(
      'You do not need an hour in the gym every day. Short, focused sessions done consistently beat long sessions done rarely.',
      "Har kuni zalda bir soat o'tirish shart emas. Muntazam qilingan qisqa, aniq mashg'ulotlar kamdan-kam qilingan uzun mashg'ulotlardan samaraliroq.",
      'Не нужно проводить в зале по часу каждый день. Короткие регулярные тренировки эффективнее длинных, но редких.',
    ),
    Tr(
      'Try 10 minutes of mobility in the morning, a 15-minute bodyweight circuit at lunch, and a short walk after dinner.',
      "Ertalab 10 daqiqa harakatchanlik mashqi, tushlikda 15 daqiqalik o'z vazningiz bilan aylanma mashg'ulot va kechki ovqatdan keyin qisqa sayr qilib ko'ring.",
      'Попробуйте 10 минут мобильности утром, 15-минутный круг с собственным весом в обед и короткую прогулку после ужина.',
    ),
  ],
  'a3': [
    Tr(
      'Muscles grow while you rest. Aim for 7–9 hours of sleep and keep a consistent schedule, even on weekends.',
      "Mushaklar dam olayotganingizda o'sadi. 7–9 soat uxlashga harakat qiling va dam olish kunlari ham bir xil tartibga rioya qiling.",
      'Мышцы растут во время отдыха. Старайтесь спать 7–9 часов и соблюдать режим даже в выходные.',
    ),
  ],
};

// ---------------------------------------------------------------------------
// Hamjamiyat (kalit — post / challenge id)
// ---------------------------------------------------------------------------

const postTexts = <String, Tr>{
  'p1': Tr(
    'Finished my first 30-day plank challenge! Any tips for the next step?',
    "Birinchi 30 kunlik planka challenge'ini tugatdim! Keyingi qadam uchun maslahat bormi?",
    'Закончила свой первый 30-дневный челлендж с планкой! Есть советы, что дальше?',
  ),
  'p2': Tr(
    'What do you eat before a morning workout? Oatmeal or nothing at all?',
    "Ertalabki mashg'ulotdan oldin nima yeysizlar? Suli bo'tqasimi yoki umuman hech narsami?",
    'Что вы едите перед утренней тренировкой? Овсянку или вообще ничего?',
  ),
  'p3': Tr(
    'Leg day routine from the app is brutal 🔥 Down 3 kg in a month.',
    "Ilovadagi «Oyoqlar kuni» juda og'ir 🔥 Bir oyda 3 kg tashladim.",
    'Тренировка «День ног» из приложения — жёсткая 🔥 Минус 3 кг за месяц.',
  ),
};

const challengeTitles = <String, Tr>{
  'c1': Tr('10K Steps a Day', 'Kuniga 10 ming qadam', '10 тысяч шагов в день'),
  'c2': Tr(
    'Plank With Hip Twist',
    'Son burab planka',
    'Планка со скручиванием',
  ),
  'c3': Tr('30 Days of Push Ups', '30 kunlik otjimaniya', '30 дней отжиманий'),
};

const challengeDescriptions = <String, Tr>{
  'c1': Tr(
    'Walk at least 10,000 steps every day for a week.',
    'Bir hafta davomida har kuni kamida 10 000 qadam yuring.',
    'Проходите не менее 10 000 шагов каждый день в течение недели.',
  ),
  'c2': Tr(
    'Weekly challenge: 3 sets of 45 seconds daily.',
    "Haftalik musobaqa: har kuni 45 soniyadan 3 set.",
    'Челлендж недели: 3 подхода по 45 секунд ежедневно.',
  ),
  'c3': Tr(
    'Start with 10 and add 2 more every day.',
    "10 tadan boshlang va har kuni 2 tadan qo'shing.",
    'Начните с 10 и добавляйте по 2 каждый день.',
  ),
};

/// Mashg'ulot tavsiflari — nima ekani va kimga mos (katta karta va "Haqida" bo'limi).
const routineDescriptions = <String, Tr>{
  'b1': Tr(
    'A gentle full-body session: basic moves for every major muscle. Perfect for your first weeks.',
    "Butun tana uchun yengil mashg'ulot: barcha asosiy mushaklarga oddiy harakatlar. Dastlabki haftalar uchun ideal.",
    'Лёгкая тренировка на всё тело: базовые движения для всех основных мышц. Идеальна для первых недель.',
  ),
  'b2': Tr(
    'Slow stretching to wake up the body, improve flexibility and reduce stiffness after sleep.',
    "Tanani uyg'otish, egiluvchanlikni oshirish va uyqudan keyingi qotib qolishni yo'qotish uchun sekin cho'zilish.",
    'Медленная растяжка, чтобы разбудить тело, улучшить гибкость и снять скованность после сна.',
  ),
  'i1': Tr(
    'Push-ups, rows and presses for a stronger chest, back, shoulders and arms.',
    "Ko'krak, orqa, yelka va qo'llarni kuchaytirish uchun otjimaniya, tortish va jim mashqlari.",
    'Отжимания, тяги и жимы для сильной груди, спины, плеч и рук.',
  ),
  'i2': Tr(
    'Squats, lunges and bridges: strong legs and glutes — the biggest calorie burners in the body.',
    "O'tirib-turish, hamla va ko'prik: kuchli oyoq va dumba — tanadagi eng ko'p kaloriya yoqadigan mushaklar.",
    'Приседания, выпады и мостики: сильные ноги и ягодицы — самые «энергозатратные» мышцы тела.',
  ),
  'a1': Tr(
    'HIIT (High-Intensity Interval Training) alternates short bursts of very hard effort with rest or easy pace. Burns a lot of calories in little time.',
    "HIIT (High-Intensity Interval Training) — juda og'ir yuklamaning qisqa davrlari dam olish yoki sekin sur'at bilan almashinadigan mashg'ulot. Qisqa vaqtda ko'p kaloriya yoqadi.",
    'HIIT (High-Intensity Interval Training) — это вид тренировки, который чередует короткие периоды очень тяжёлой нагрузки и периоды отдыха или слабого темпа. Сжигает много калорий за короткое время.',
  ),
  'a2': Tr(
    'Heavy compound lifts — deadlift, bench press, pull-ups — for maximum strength. For experienced athletes.',
    "Og'ir bazaviy mashqlar — stanovaya, jim, turnik — maksimal kuch uchun. Tajribali sportchilar uchun.",
    'Тяжёлые базовые упражнения — становая, жим, подтягивания — для максимальной силы. Для опытных спортсменов.',
  ),
};
