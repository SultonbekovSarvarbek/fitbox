import 'package:flutter/material.dart';

import '../../../core/content/content_l10n.dart';

enum NewsCategory { nutrition, sport, supplements, recipes }

extension NewsCategoryInfo on NewsCategory {
  Tr get label => switch (this) {
    NewsCategory.nutrition => const Tr('Nutrition', 'Ovqatlanish', 'Питание'),
    NewsCategory.sport => const Tr('Sport', 'Sport', 'Спорт'),
    NewsCategory.supplements => const Tr(
      'Supplements',
      "Qo'shimchalar",
      'Добавки',
    ),
    NewsCategory.recipes => const Tr('Recipes', 'Retseptlar', 'Рецепты'),
  };

  IconData get icon => switch (this) {
    NewsCategory.nutrition => Icons.restaurant_rounded,
    NewsCategory.sport => Icons.directions_run_rounded,
    NewsCategory.supplements => Icons.science_outlined,
    NewsCategory.recipes => Icons.ramen_dining_rounded,
  };

  Color get color => switch (this) {
    NewsCategory.nutrition => const Color(0xFF34C759),
    NewsCategory.sport => const Color(0xFFFF9F0A),
    NewsCategory.supplements => const Color(0xFF8E7CFF),
    NewsCategory.recipes => const Color(0xFFFFD60A),
  };
}

/// Yangilik / maqola: ovqatlanish va sport bo'yicha tushuntiruvchi materiallar.
///
/// ⚠️ DEMO kontent: umumiy ma'lumot, tibbiy maslahat emas.
/// TODO(backend/admin): yangiliklar admin paneldan, har bir tilda, rasm bilan.
class NewsItem {
  const NewsItem({
    required this.id,
    required this.category,
    required this.date,
    required this.minutes,
    required this.title,
    required this.summary,
    required this.body,
    this.productId,
    this.toSubscription = false,
  });

  final String id;
  final NewsCategory category;
  final DateTime date;

  /// O'qish vaqti (daqiqa).
  final int minutes;
  final Tr title;

  /// Qisqa kirish — ro'yxatda va maqola boshida.
  final Tr summary;
  final List<Tr> body;

  /// Maqolaga bog'liq mahsulot (do'kondagi id) — "Do'konda ko'rish".
  final String? productId;

  /// Ovqat obunasiga havola ko'rsatiladimi.
  final bool toSubscription;
}

NewsItem? newsById(String id) => news.where((n) => n.id == id).firstOrNull;

/// Eng yangilari birinchi.
List<NewsItem> newsSorted([NewsCategory? category]) =>
    (news.where((n) => category == null || n.category == category).toList()
      ..sort((a, b) => b.date.compareTo(a.date)));

/// Bosh yangilik: eng yangi "featured".
NewsItem get featuredNews => news.firstWhere(
  (n) => n.id == 'protein-need',
  orElse: () => newsSorted().first,
);

/// Shu kategoriyadagi boshqa maqolalar ("Yana o'qing").
List<NewsItem> relatedNews(NewsItem item, {int take = 3}) =>
    newsSorted(item.category).where((n) => n.id != item.id).take(take).toList();

final news = <NewsItem>[
  // ---------------------------------------------------------------- Ovqatlanish
  NewsItem(
    id: 'protein-need',
    category: NewsCategory.nutrition,
    date: DateTime(2026, 10, 16),
    minutes: 4,
    title: Tr(
      'How much protein do you really need?',
      'Sizga aslida qancha oqsil kerak?',
      'Сколько белка вам на самом деле нужно?',
    ),
    summary: Tr(
      'A simple rule by body weight and goal, and why spreading it over the day helps.',
      "Vazn va maqsadga qarab oddiy qoida va nega uni kun bo'ylab taqsimlash yaxshi.",
      'Простое правило по весу и цели и почему белок лучше распределять в течение дня.',
    ),
    body: [
      Tr(
        'For most healthy adults the minimum is about 0.8 g of protein per kg of body weight. If you train regularly, a commonly recommended range is 1.4–2.0 g per kg. For a 70 kg person that is roughly 100–140 g a day.',
        "Ko'pchilik sog'lom kattalar uchun minimum — tana vazniga 0,8 g/kg atrofida oqsil. Muntazam mashq qilsangiz, odatda 1,4–2,0 g/kg tavsiya etiladi. 70 kg odam uchun bu kuniga taxminan 100–140 g.",
        'Для большинства здоровых взрослых минимум — около 0,8 г белка на кг веса. Если вы регулярно тренируетесь, обычно рекомендуют 1,4–2,0 г на кг. Для человека весом 70 кг это примерно 100–140 г в день.',
      ),
      Tr(
        'Spread protein over 3–4 meals, about 20–40 g each, instead of eating most of it at dinner. Good sources are eggs, chicken, fish, lean beef, cottage cheese, yogurt, lentils and beans.',
        "Oqsilni ko'p qismini kechki ovqatga qoldirmasdan, 3–4 ta ovqatga, har birida taxminan 20–40 g dan taqsimlang. Yaxshi manbalar: tuxum, tovuq, baliq, yog'siz mol go'shti, tvorog, yogurt, yasmiq va loviya.",
        'Распределяйте белок на 3–4 приёма пищи, примерно по 20–40 г, а не съедайте основную часть на ужин. Хорошие источники: яйца, курица, рыба, постная говядина, творог, йогурт, чечевица и фасоль.',
      ),
      Tr(
        'Protein powder is just convenient food: it does not work better than eggs or chicken. Use it when you cannot reach your target otherwise. People with kidney disease should ask a doctor before raising protein.',
        "Protein kukuni — shunchaki qulay ovqat: tuxum yoki tovuqdan yaxshiroq ishlamaydi. Maqsadga boshqacha erisha olmasangiz foydalaning. Buyrak kasalligi bo'lganlar oqsilni oshirishdan oldin shifokorga murojaat qilsin.",
        'Протеин в порошке — просто удобная еда: он не работает лучше яиц или курицы. Используйте его, если иначе не получается добрать норму. При болезнях почек перед увеличением белка нужно посоветоваться с врачом.',
      ),
    ],
    productId: 'whey-isolate',
  ),
  NewsItem(
    id: 'carbs-not-enemy',
    category: NewsCategory.nutrition,
    date: DateTime(2026, 10, 14),
    minutes: 4,
    title: Tr(
      'Carbs are not the enemy: how to choose them',
      "Uglevodlar dushman emas: ularni qanday tanlash kerak",
      'Углеводы — не враг: как их выбирать',
    ),
    summary: Tr(
      'Slow carbs give energy for training and keep you full. Sugary drinks and sweets are what to limit.',
      "Sekin uglevodlar mashq uchun energiya beradi va to'qlik saqlaydi. Cheklash kerak bo'lgani — shirin ichimliklar va shirinliklar.",
      'Медленные углеводы дают энергию для тренировок и надолго насыщают. Ограничивать стоит сладкие напитки и сладости.',
    ),
    body: [
      Tr(
        'Carbohydrates are the main fuel for intense training. Choose slow sources: oats, buckwheat, rice, potatoes, whole-grain bread, legumes and fruit. They digest gradually and come with fiber.',
        "Uglevodlar jadal mashq uchun asosiy yoqilg'i. Sekin manbalarni tanlang: suli, grechka, guruch, kartoshka, to'liq donli non, dukkakli va mevalar. Ular asta hazm bo'ladi va tolaga boy.",
        'Углеводы — основное топливо для интенсивных тренировок. Выбирайте медленные источники: овсянку, гречку, рис, картофель, цельнозерновой хлеб, бобовые и фрукты. Они усваиваются постепенно и содержат клетчатку.',
      ),
      Tr(
        'Aim for roughly 25–30 g of fiber a day. The WHO suggests keeping free sugars below 10% of daily energy, and ideally below 5%, which is about 25 g for most adults. Sweet drinks are the easiest place to cut.',
        "Kuniga taxminan 25–30 g tola oling. JSST erkin shakarni kunlik energiyaning 10% dan kam, ideal holda 5% dan kam (ko'pchilik uchun ~25 g) ushlashni tavsiya qiladi. Eng oson qisqartiriladigani — shirin ichimliklar.",
        'Старайтесь получать около 25–30 г клетчатки в день. ВОЗ советует держать свободные сахара ниже 10% суточной энергии, а лучше ниже 5% — это около 25 г для большинства взрослых. Проще всего сократить сладкие напитки.',
      ),
      Tr(
        'Put more carbs around training days and fewer on rest days if your goal is fat loss. Do not cut carbs to zero: you will train worse and be hungrier.',
        "Ozmoqchi bo'lsangiz, uglevodlarni mashq kunlarida ko'proq, dam kunlarida kamroq qiling. Ularni nolga tushirmang: mashq yomonlashadi va ochlik kuchayadi.",
        'Если цель — похудение, ешьте больше углеводов в дни тренировок и меньше в дни отдыха. Не убирайте их полностью: вы будете хуже тренироваться и сильнее хотеть есть.',
      ),
    ],
  ),
  NewsItem(
    id: 'pre-post-workout',
    category: NewsCategory.nutrition,
    date: DateTime(2026, 10, 12),
    minutes: 4,
    title: Tr(
      'What to eat before and after a workout',
      "Mashg'ulotdan oldin va keyin nima yeyish kerak",
      'Что есть до и после тренировки',
    ),
    summary: Tr(
      'Timing matters less than total daily intake, but a few simple habits make training feel better.',
      "Vaqt kunlik umumiy iste'moldan kamroq muhim, ammo bir nechta oddiy odat mashqni yengillashtiradi.",
      'Время приёма важно меньше, чем общий рацион за день, но несколько простых привычек делают тренировку легче.',
    ),
    body: [
      Tr(
        'Eat a meal 1–3 hours before training: carbohydrates plus some protein, and not too much fat or fiber. For example rice with chicken, or oatmeal with yogurt. If you have less than an hour, a banana or a yogurt is enough.',
        "Mashqdan 1–3 soat oldin ovqatlaning: uglevod va ozroq oqsil, yog' va tola ko'p bo'lmasin. Masalan, tovuqli guruch yoki yogurtli suli. Bir soatdan kam vaqt bo'lsa — banan yoki yogurt yetarli.",
        'Поешьте за 1–3 часа до тренировки: углеводы и немного белка, без избытка жира и клетчатки. Например, рис с курицей или овсянка с йогуртом. Если времени меньше часа, хватит банана или йогурта.',
      ),
      Tr(
        'After training have 20–40 g of protein and some carbohydrates within a couple of hours. The so-called anabolic window is much wider than people think, so there is no need to rush with a shaker in the locker room.',
        "Mashqdan keyin bir-ikki soat ichida 20–40 g oqsil va ozroq uglevod oling. «Anabolik oyna» odamlar o'ylaganidan ancha keng, shuning uchun kiyinish xonasida shoshilish shart emas.",
        'После тренировки в течение пары часов получите 20–40 г белка и немного углеводов. «Анаболическое окно» гораздо шире, чем принято думать, так что спешить с шейкером в раздевалке не нужно.',
      ),
      Tr(
        'Drink water through the session. If you train early and feel weak on an empty stomach, try something small like a banana first.',
        "Mashq davomida suv iching. Ertalab ochqoringa holsiz bo'lsangiz, avval banan kabi kichik narsa yeng.",
        'Пейте воду во время тренировки. Если вы занимаетесь рано и чувствуете слабость натощак, съешьте что-нибудь небольшое, например банан.',
      ),
    ],
  ),
  NewsItem(
    id: 'water',
    category: NewsCategory.nutrition,
    date: DateTime(2026, 10, 9),
    minutes: 3,
    title: Tr(
      'How much water do you actually need?',
      'Sizga aslida qancha suv kerak?',
      'Сколько воды вам нужно на самом деле?',
    ),
    summary: Tr(
      'A practical starting point and a simple colour check instead of the "8 glasses" myth.',
      "«8 stakan» afsonasi o'rniga amaliy boshlang'ich nuqta va oddiy rang tekshiruvi.",
      'Практичная отправная точка и простая проверка по цвету вместо мифа про «8 стаканов».',
    ),
    body: [
      Tr(
        'Needs depend on weight, heat and activity. A practical starting point is about 30–35 ml per kg of body weight a day from all drinks and food. Tea and coffee count too.',
        "Ehtiyoj vazn, issiqlik va faollikka bog'liq. Amaliy boshlang'ich nuqta — kuniga barcha ichimlik va ovqatdan tana vazniga ~30–35 ml/kg. Choy va qahva ham hisobga olinadi.",
        'Потребность зависит от веса, жары и активности. Практичная отправная точка — около 30–35 мл на кг веса в день из всех напитков и еды. Чай и кофе тоже считаются.',
      ),
      Tr(
        'The easiest check is the colour of urine: pale yellow means you are fine, dark means drink more. During intense training in the heat add roughly 400–800 ml per hour.',
        "Eng oddiy tekshiruv — siydik rangi: och sariq — yaxshi, to'q — ko'proq iching. Issiqda jadal mashq paytida soatiga taxminan 400–800 ml qo'shing.",
        'Проще всего проверить по цвету мочи: бледно-жёлтый — всё хорошо, тёмный — пейте больше. При интенсивной тренировке в жару добавляйте примерно 400–800 мл в час.',
      ),
      Tr(
        'Do not force huge amounts in a short time: drinking far more than you need does not help and can be harmful. Sip through the day instead.',
        "Qisqa vaqtda juda ko'p suv ichishga majburlamang: kerakdan ortiq ichish foyda bermaydi va zarar qilishi mumkin. Kun bo'yi ozdan-ozdan iching.",
        'Не заставляйте себя выпивать огромные объёмы за короткое время: пить сильно больше нормы бесполезно и может навредить. Лучше пейте небольшими порциями в течение дня.',
      ),
    ],
  ),
  NewsItem(
    id: 'read-label',
    category: NewsCategory.nutrition,
    date: DateTime(2026, 10, 6),
    minutes: 4,
    title: Tr(
      'How to read a nutrition label in 30 seconds',
      "Oziq-ovqat yorlig'ini 30 soniyada qanday o'qish kerak",
      'Как прочитать этикетку за 30 секунд',
    ),
    summary: Tr(
      'Serving size, sugar, salt and the ingredient list: four things that tell you most of the story.',
      "Porsiya hajmi, shakar, tuz va tarkib ro'yxati: ko'p narsani aytib beradigan to'rt narsa.",
      'Размер порции, сахар, соль и состав: четыре вещи, которые рассказывают почти всё.',
    ),
    body: [
      Tr(
        'Start with the serving size: the numbers on the pack are often for 30 or 100 g, not for the whole package. Then look at sugars, and especially added sugar, and at salt. The WHO recommends less than 5 g of salt a day.',
        "Porsiya hajmidan boshlang: qadoqdagi raqamlar ko'pincha butun qadoq uchun emas, 30 yoki 100 g uchun. Keyin shakarga (ayniqsa qo'shilgan shakar) va tuzga qarang. JSST kuniga 5 g dan kam tuzni tavsiya qiladi.",
        'Начните с размера порции: цифры на упаковке часто указаны на 30 или 100 г, а не на всю пачку. Затем смотрите на сахар, особенно добавленный, и на соль. ВОЗ рекомендует меньше 5 г соли в день.',
      ),
      Tr(
        'Ingredients are listed from the largest amount to the smallest. If sugar or syrup is near the top, it is dessert, whatever the front of the pack says. For bars and snacks compare protein per 100 kcal.',
        "Tarkib eng ko'pidan eng kamigacha yoziladi. Shakar yoki sirop boshida bo'lsa, qadoq old tomonida nima yozilgan bo'lmasin, bu shirinlik. Batonchik va gazaklarda 100 kkalga to'g'ri keladigan oqsilni solishtiring.",
        'Состав перечисляется от большего количества к меньшему. Если сахар или сироп в начале списка, это десерт, что бы ни было написано на лицевой стороне. У батончиков и снеков сравнивайте белок на 100 ккал.',
      ),
      Tr(
        '"Sugar-free" does not mean calorie-free. Sugar alcohols such as sorbitol or maltitol can cause bloating in larger amounts.',
        "«Shakarsiz» — kaloriyasiz degani emas. Sorbit yoki maltit kabi shakar spirtlari ko'p bo'lsa shishishga olib kelishi mumkin.",
        '«Без сахара» не значит «без калорий». Сахарные спирты, такие как сорбит или мальтит, в большом количестве могут вызывать вздутие.',
      ),
    ],
  ),
  NewsItem(
    id: 'meal-prep',
    category: NewsCategory.nutrition,
    date: DateTime(2026, 10, 3),
    minutes: 5,
    title: Tr(
      'Meal prep for a busy week: 90 minutes on Sunday',
      "Band hafta uchun ovqat tayyorlash: yakshanba kuni 90 daqiqa",
      'Заготовка еды на занятую неделю: 90 минут в воскресенье',
    ),
    summary: Tr(
      'Cook once, eat well all week. And what to do if you have no time at all.',
      "Bir marta pishiring, butun hafta yaxshi ovqatlaning. Vaqt umuman bo'lmasa nima qilish kerak.",
      'Приготовьте один раз — и питайтесь хорошо всю неделю. И что делать, если времени нет совсем.',
    ),
    body: [
      Tr(
        'Cook a big batch of a carbohydrate (rice, buckwheat or potatoes), a batch of protein (baked chicken, lean meat, boiled eggs) and chop vegetables. Then you only need to combine them into boxes every day.',
        "Katta qismda uglevod (guruch, grechka yoki kartoshka), oqsil (pishirilgan tovuq, yog'siz go'sht, qaynatilgan tuxum) tayyorlang va sabzavotlarni to'g'rang. Keyin har kuni ularni qutilarga yig'ishning o'zi yetadi.",
        'Приготовьте большую порцию углеводов (рис, гречка или картофель), порцию белка (запечённая курица, постное мясо, варёные яйца) и нарежьте овощи. Потом останется только собирать контейнеры каждый день.',
      ),
      Tr(
        'Cooked food keeps 3–4 days in the fridge; freeze the rest. In hot weather do not leave it out for more than two hours, and cool it quickly before closing the box.',
        "Pishgan ovqat muzlatgichda 3–4 kun saqlanadi; qolganini muzlating. Issiq havoda ikki soatdan ortiq tashqarida qoldirmang va qutini yopishdan oldin tez sovuting.",
        'Готовая еда хранится в холодильнике 3–4 дня, остальное заморозьте. В жару не оставляйте её на столе дольше двух часов и быстро остужайте перед тем, как закрыть контейнер.',
      ),
      Tr(
        'If you have no time even for this, our meal programs bring fresh breakfast, lunch and dinner to your door every day, calculated for your goal.',
        "Agar bunga ham vaqtingiz bo'lmasa, bizning ovqat ratsionlarimiz har kuni eshigingizgacha yangi nonushta, tushlik va kechki ovqat olib keladi, maqsadingizga mos hisoblangan.",
        'Если нет времени даже на это, наши программы питания привозят свежие завтрак, обед и ужин к вашей двери каждый день, рассчитанные под вашу цель.',
      ),
    ],
    toSubscription: true,
  ),
  NewsItem(
    id: 'uzbek-table',
    category: NewsCategory.nutrition,
    date: DateTime(2026, 9, 30),
    minutes: 5,
    title: Tr(
      'A lighter Uzbek table: plov, manti and samsa without guilt',
      "Yengilroq o'zbek dasturxoni: osh, manti va somsa aybsiz",
      'Лёгкий узбекский стол: плов, манты и самса без чувства вины',
    ),
    summary: Tr(
      'You do not have to give up the dishes you love. Portion size and the amount of oil do most of the work.',
      "Yaxshi ko'rgan taomlaringizdan voz kechish shart emas. Ishning ko'pini porsiya hajmi va yog' miqdori qiladi.",
      'Отказываться от любимых блюд не нужно. Основную работу делают размер порции и количество масла.',
    ),
    body: [
      Tr(
        'Plov: use leaner meat, cut the oil by about a third, add more carrots, and serve a portion of 200–250 g with a fresh tomato and onion salad. Eat slowly and do not take seconds on autopilot.',
        "Osh: yog'siz go'sht ishlating, yog'ni taxminan uchdan bir qismga kamaytiring, sabzini ko'proq soling va 200–250 g porsiyani yangi pomidor-piyoz salati bilan torting. Sekin yeng va mexanik ravishda qo'shimcha olmang.",
        'Плов: берите более постное мясо, уменьшите масло примерно на треть, добавьте больше моркови и подавайте порцию 200–250 г со свежим салатом из помидоров и лука. Ешьте медленно и не берите добавку на автомате.',
      ),
      Tr(
        'Manti and chuchvara: steam instead of frying, make the filling with pumpkin or lean meat, and serve with plain yogurt instead of fatty sour cream. Mastava and shurpa are good choices when made with less oil.',
        "Manti va chuchvara: qovurmasdan bug'da pishiring, ichiga qovoq yoki yog'siz go'sht soling va yog'li smetana o'rniga oddiy yogurt bilan torting. Mastava va sho'rva yog' kam bo'lsa yaxshi tanlov.",
        'Манты и чучвара: готовьте на пару, а не жарьте, делайте начинку из тыквы или постного мяса и подавайте с натуральным йогуртом вместо жирной сметаны. Мастава и шурпа — хороший выбор, если готовить с меньшим количеством масла.',
      ),
      Tr(
        'Samsa is delicious but dense: treat it as a meal rather than a snack, and balance the day with vegetables and protein.',
        "Somsa mazali, lekin to'yimli: uni gazak emas, to'liq ovqat deb hisoblang va kunni sabzavot hamda oqsil bilan muvozanatlang.",
        'Самса вкусная, но калорийная: считайте её полноценным приёмом пищи, а не перекусом, и уравновесьте день овощами и белком.',
      ),
    ],
  ),
  // ---------------------------------------------------------------------- Sport
  NewsItem(
    id: 'who-150',
    category: NewsCategory.sport,
    date: DateTime(2026, 10, 15),
    minutes: 3,
    title: Tr(
      '150 minutes a week: what the WHO actually recommends',
      "Haftasiga 150 daqiqa: JSST aslida nima tavsiya qiladi",
      '150 минут в неделю: что на самом деле рекомендует ВОЗ',
    ),
    summary: Tr(
      'The minimum amount of movement for health, and how to fit it into a normal week.',
      "Salomatlik uchun harakatning minimal miqdori va uni oddiy haftaga qanday sig'dirish.",
      'Минимум движения для здоровья и как уместить его в обычную неделю.',
    ),
    body: [
      Tr(
        'Adults are advised to get 150–300 minutes of moderate activity a week, or 75–150 minutes of vigorous activity, plus muscle-strengthening exercises on at least two days. Moderate means you can talk but not sing.',
        "Kattalarga haftasiga 150–300 daqiqa o'rtacha yoki 75–150 daqiqa jadal faollik, hamda kamida ikki kun mushak kuchaytiruvchi mashqlar tavsiya etiladi. O'rtacha — gaplasha olasiz, lekin kuylay olmaysiz.",
        'Взрослым рекомендуют 150–300 минут умеренной активности в неделю или 75–150 минут интенсивной, плюс силовые упражнения минимум два дня. Умеренная нагрузка — когда вы можете говорить, но не петь.',
      ),
      Tr(
        'It does not have to be one long session. Three brisk 10-minute walks a day add up to 210 minutes a week. Start with what you can keep up and add five minutes at a time.',
        "Bu bitta uzoq mashg'ulot bo'lishi shart emas. Kuniga uch marta 10 daqiqalik tez yurish haftasiga 210 daqiqani beradi. Davom ettira oladigan darajadan boshlang va besh daqiqadan qo'shing.",
        'Это не обязательно одна долгая тренировка. Три быстрые прогулки по 10 минут в день дают 210 минут в неделю. Начните с того, что сможете выдерживать, и добавляйте по пять минут.',
      ),
      Tr(
        'Even a little is better than nothing: the biggest health gain comes from moving from no activity to some.',
        "Ozgina ham umuman yo'qdan yaxshi: eng katta foyda umuman harakatsizlikdan ozgina harakatga o'tishda bo'ladi.",
        'Даже немного лучше, чем ничего: самая большая польза для здоровья — при переходе от полной неактивности к хоть какой-то.',
      ),
    ],
  ),
  NewsItem(
    id: 'strength-beginner',
    category: NewsCategory.sport,
    date: DateTime(2026, 10, 13),
    minutes: 5,
    title: Tr(
      'Strength training for beginners: a simple 3-day plan',
      "Yangi boshlovchilar uchun kuch mashqlari: oddiy 3 kunlik reja",
      'Силовые для начинающих: простой план на 3 дня',
    ),
    summary: Tr(
      'Five movement patterns, two or three sets, and slow progress. That is all you need at the start.',
      "Beshta harakat turi, ikki-uch yondashuv va sekin o'sish. Boshida shuning o'zi yetadi.",
      'Пять базовых движений, два-три подхода и медленный прогресс. На старте этого достаточно.',
    ),
    body: [
      Tr(
        'Train three days a week with a day of rest between. Each session is full-body: a squat or leg press, a push (push-ups or bench press), a pull (a row), a hip hinge (deadlift or glute bridge) and a plank.',
        "Haftasiga uch kun mashq qiling, orasida dam kuni. Har bir mashg'ulot butun tanaga: o'tirib-turish yoki oyoq press, itarish (otjimaniya yoki jim), tortish (tortma), son bukilishi (deadlift yoki glute bridge) va planka.",
        'Тренируйтесь три дня в неделю с днём отдыха между ними. Каждая тренировка на всё тело: присед или жим ногами, жим (отжимания или жим лёжа), тяга, наклон с отведением таза (становая или ягодичный мостик) и планка.',
      ),
      Tr(
        'Do 2–3 sets of 8–12 repetitions and stop with about two repetitions left in reserve. Add a little weight or one repetition when it feels easy. Technique first: learn the movement with a light weight or ask a coach to check you.',
        "2–3 yondashuv, har birida 8–12 takror qiling va taxminan ikkita takror zaxirada qolganda to'xtang. Yengil tuyulsa ozgina og'irlik yoki bitta takror qo'shing. Avval texnika: harakatni yengil og'irlikda o'rganing yoki murabbiydan tekshirishni so'rang.",
        'Делайте 2–3 подхода по 8–12 повторений и останавливайтесь, когда в запасе остаётся примерно два повторения. Добавляйте немного веса или одно повторение, когда становится легко. Сначала техника: осваивайте движение с лёгким весом или попросите тренера проверить.',
      ),
      Tr(
        'Warm up for five minutes and eat enough protein. The first weeks of progress come from your nervous system learning the movement, so do not be discouraged if the mirror does not change yet.',
        "Besh daqiqa qizining va yetarli oqsil iste'mol qiling. Dastlabki haftalardagi o'sish asab tizimining harakatni o'rganishidan keladi, shuning uchun ko'zgu hali o'zgarmasa tushkunlikka tushmang.",
        'Разминайтесь пять минут и ешьте достаточно белка. Прогресс в первые недели — это нервная система учится движению, поэтому не расстраивайтесь, если зеркало пока не меняется.',
      ),
    ],
  ),
  NewsItem(
    id: 'first-5k',
    category: NewsCategory.sport,
    date: DateTime(2026, 10, 10),
    minutes: 4,
    title: Tr(
      'Your first 5 km in eight weeks',
      "Sakkiz haftada birinchi 5 km",
      'Первые 5 км за восемь недель',
    ),
    summary: Tr(
      'A run–walk plan for people who have never run, and the mistakes that cause injuries.',
      "Hech qachon yugurmagan odamlar uchun yugurish–yurish rejasi va jarohatga olib keladigan xatolar.",
      'План «бег–ходьба» для тех, кто никогда не бегал, и ошибки, которые приводят к травмам.',
    ),
    body: [
      Tr(
        'Run three times a week. In week 1 alternate 1 minute of easy running with 2 minutes of walking for about 20 minutes. Each week lengthen the running part and shorten the walking part until you can run 25–30 minutes without stopping.',
        "Haftasiga uch marta yuguring. 1-haftada taxminan 20 daqiqa davomida 1 daqiqa yengil yugurish va 2 daqiqa yurishni almashtiring. Har hafta yugurish qismini uzaytirib, yurish qismini qisqartiring, to 25–30 daqiqa to'xtamasdan yugura olgunizcha.",
        'Бегайте три раза в неделю. На 1-й неделе чередуйте 1 минуту лёгкого бега с 2 минутами ходьбы около 20 минут. Каждую неделю удлиняйте бег и сокращайте ходьбу, пока не сможете бежать 25–30 минут без остановки.',
      ),
      Tr(
        'Run at an easy pace: you should be able to speak in short sentences. Most beginners go too fast. Increase the weekly total gradually, by no more than about 10%.',
        "Yengil sur'atda yuguring: qisqa gaplar bilan gapira olishingiz kerak. Ko'pchilik yangi boshlovchilar juda tez yuguradi. Haftalik umumiy hajmni asta oshiring, taxminan 10% dan ko'p emas.",
        'Бегите в лёгком темпе: вы должны мочь говорить короткими фразами. Большинство новичков бегут слишком быстро. Увеличивайте недельный объём постепенно, не более чем примерно на 10%.',
      ),
      Tr(
        'Choose comfortable running shoes and keep rest days. A sharp or growing pain is a reason to stop and rest; if it does not pass, see a doctor.',
        "Qulay yugurish poyabzalini tanlang va dam kunlarini saqlang. O'tkir yoki kuchayib boruvchi og'riq — to'xtab dam olish sababi; o'tmasa, shifokorga boring.",
        'Выберите удобную беговую обувь и не отказывайтесь от дней отдыха. Резкая или нарастающая боль — повод остановиться и отдохнуть; если не проходит, обратитесь к врачу.',
      ),
    ],
  ),
  NewsItem(
    id: 'sleep',
    category: NewsCategory.sport,
    date: DateTime(2026, 10, 8),
    minutes: 4,
    title: Tr(
      'Why sleep builds muscle and burns fat',
      "Nega uyqu mushak quradi va yog'ni yoqadi",
      'Почему сон наращивает мышцы и помогает худеть',
    ),
    summary: Tr(
      'Training is the signal, sleep is where the body adapts. Seven simple habits for better nights.',
      "Mashq — signal, uyqu esa organizm moslashadigan vaqt. Yaxshiroq tun uchun oddiy odatlar.",
      'Тренировка — сигнал, а адаптация происходит во сне. Простые привычки для лучшего сна.',
    ),
    body: [
      Tr(
        'Most adults need 7–9 hours. When you sleep badly you recover worse, feel hungrier, crave sugar and train with less power. A consistent schedule, even on weekends, helps more than a single long sleep-in.',
        "Ko'pchilik kattalarga 7–9 soat kerak. Yomon uxlasangiz, tiklanish yomonlashadi, ochlik va shirinlikka ishtiyoq kuchayadi, mashq kuchsizroq bo'ladi. Dam olish kunlarida ham bir xil tartib bitta uzoq uxlashdan ko'ra foydaliroq.",
        'Большинству взрослых нужно 7–9 часов. При плохом сне хуже восстанавливаетесь, сильнее хотите есть и тянет на сладкое, а тренируетесь с меньшей силой. Стабильный режим, в том числе в выходные, помогает больше, чем один долгий сон.',
      ),
      Tr(
        'Keep the bedroom cool, dark and quiet. Stop caffeine about 8 hours before bed, avoid heavy meals late at night and put the phone away for the last half hour.',
        "Yotoqxonani salqin, qorong'i va tinch saqlang. Uxlashdan taxminan 8 soat oldin kofeinni to'xtating, kechasi og'ir ovqat yemang va oxirgi yarim soatda telefonni chetga qo'ying.",
        'Держите спальню прохладной, тёмной и тихой. Прекращайте кофеин примерно за 8 часов до сна, не ешьте тяжело поздно вечером и уберите телефон за полчаса до сна.',
      ),
      Tr(
        'A short nap of 20–30 minutes can help after a bad night. If you sleep badly for weeks, speak to a doctor.',
        "Yomon tundan keyin 20–30 daqiqalik qisqa uyqu yordam beradi. Agar haftalab yomon uxlasangiz, shifokorga murojaat qiling.",
        'После плохой ночи может помочь короткий дневной сон на 20–30 минут. Если вы плохо спите несколько недель, обратитесь к врачу.',
      ),
    ],
  ),
  NewsItem(
    id: 'warmup',
    category: NewsCategory.sport,
    date: DateTime(2026, 10, 5),
    minutes: 3,
    title: Tr(
      'A five-minute warm-up that actually works',
      "Haqiqatan ishlaydigan besh daqiqalik qizdirish",
      'Разминка на пять минут, которая реально работает',
    ),
    summary: Tr(
      'Raise your temperature, move the joints you will use, then start light. No need for a long routine.',
      "Haroratni ko'taring, ishlatadigan bo'g'imlaringizni harakatlantiring va yengildan boshlang. Uzoq tartib kerak emas.",
      'Поднимите температуру тела, подвигайте суставы, которые будете использовать, и начните с лёгкого. Долгая процедура не нужна.',
    ),
    body: [
      Tr(
        'Two minutes of easy cardio (brisk walking, skipping or a bike) to warm up. Then 2–3 minutes of dynamic movements: leg swings, arm circles, hip hinges and bodyweight squats.',
        "Qizish uchun ikki daqiqa yengil kardio (tez yurish, arqon yoki velosiped). Keyin 2–3 daqiqa dinamik harakatlar: oyoq chayqatish, qo'l aylantirish, son bukilishi va o'tirib-turish.",
        'Две минуты лёгкого кардио (быстрая ходьба, скакалка или велосипед), чтобы разогреться. Затем 2–3 минуты динамических движений: махи ногами, вращения руками, наклоны с отведением таза и приседания.',
      ),
      Tr(
        'Before your first heavy exercise do one or two light sets with an empty bar or a light weight. This prepares the exact pattern you are about to load.',
        "Birinchi og'ir mashqdan oldin bo'sh shtanga yoki yengil og'irlik bilan bir-ikki yengil yondashuv qiling. Bu yuklamoqchi bo'lgan harakat shaklini tayyorlaydi.",
        'Перед первым тяжёлым упражнением сделайте один-два лёгких подхода с пустым грифом или лёгким весом. Это подготавливает именно то движение, которое вы собираетесь нагружать.',
      ),
      Tr(
        'Long static stretching is better after training or on a separate day, not right before maximum effort.',
        "Uzoq statik cho'zilish mashqdan keyin yoki alohida kunda yaxshiroq, maksimal kuch sarflashdan oldin emas.",
        'Долгая статическая растяжка лучше после тренировки или в отдельный день, а не прямо перед максимальным усилием.',
      ),
    ],
  ),
  NewsItem(
    id: 'plateau',
    category: NewsCategory.sport,
    date: DateTime(2026, 10, 1),
    minutes: 4,
    title: Tr(
      'Progress stalled? Six things to check first',
      "O'sish to'xtadimi? Avval tekshiradigan oltita narsa",
      'Прогресс остановился? Шесть вещей, которые проверить в первую очередь',
    ),
    summary: Tr(
      'Plateaus are normal. Usually the fix is boring: sleep, food, a plan and patience.',
      "Plato — normal hodisa. Odatda yechim zerikarli: uyqu, ovqat, reja va sabr.",
      'Плато — это нормально. Обычно решение скучное: сон, питание, план и терпение.',
    ),
    body: [
      Tr(
        'Check the basics first: are you sleeping 7–9 hours, eating enough protein and enough calories for your goal, and training consistently? Most stalls come from one of these.',
        "Avval asoslarni tekshiring: 7–9 soat uxlayapsizmi, maqsadingiz uchun yetarli oqsil va kaloriya olyapsizmi, muntazam mashq qilyapsizmi? Ko'pchilik to'xtashlar shulardan biridan kelib chiqadi.",
        'Сначала проверьте основы: спите ли вы 7–9 часов, едите ли достаточно белка и калорий под свою цель, тренируетесь ли регулярно? Большинство остановок — из-за одного из этого.',
      ),
      Tr(
        'Then look at the plan: keep a log, make sure you slowly add weight or repetitions, and change only one thing at a time. Every 4–8 weeks take an easier week to recover.',
        "Keyin rejaga qarang: jurnal yuriting, og'irlik yoki takrorni sekin oshirayotganingizga ishonch hosil qiling va bir vaqtda faqat bitta narsani o'zgartiring. Har 4–8 haftada tiklanish uchun yengilroq hafta qiling.",
        'Затем посмотрите на план: ведите дневник, убедитесь, что медленно добавляете вес или повторения, и меняйте только одну вещь за раз. Раз в 4–8 недель делайте более лёгкую неделю для восстановления.',
      ),
      Tr(
        'Do not judge by the scale alone: weight changes by a kilo or two a day with water and food. Compare waist measurements, photos and the weights you lift over several weeks.',
        "Faqat tarozi bo'yicha baho bermang: vazn suv va ovqat hisobiga kuniga bir-ikki kilo o'zgaradi. Bir necha hafta davomida bel o'lchami, suratlar va ko'tarayotgan og'irliklarni solishtiring.",
        'Не судите только по весам: вес колеблется на килограмм-два в день из-за воды и еды. Сравнивайте обхват талии, фотографии и рабочие веса за несколько недель.',
      ),
    ],
  ),
  // ------------------------------------------------------------------ Qo'shimchalar
  NewsItem(
    id: 'creatine-facts',
    category: NewsCategory.supplements,
    date: DateTime(2026, 10, 11),
    minutes: 4,
    title: Tr(
      'Creatine: myths and facts',
      "Kreatin: afsonalar va faktlar",
      'Креатин: мифы и факты',
    ),
    summary: Tr(
      'The most studied sports supplement. What it does, how to take it and who should be careful.',
      "Eng ko'p o'rganilgan sport qo'shimchasi. U nima qiladi, qanday qabul qilinadi va kim ehtiyot bo'lishi kerak.",
      'Самая изученная спортивная добавка. Что она делает, как её принимать и кому быть осторожным.',
    ),
    body: [
      Tr(
        'Creatine monohydrate helps muscles produce energy in short, intense efforts, so it can improve strength and the number of repetitions when combined with training. It is not a steroid and it works for women too.',
        "Kreatin monogidrat mushaklarga qisqa, jadal harakatlarda energiya ishlab chiqarishga yordam beradi, shuning uchun mashq bilan birga kuch va takrorlar sonini oshirishi mumkin. U steroid emas va ayollarga ham ta'sir qiladi.",
        'Моногидрат креатина помогает мышцам вырабатывать энергию при коротких интенсивных усилиях, поэтому в сочетании с тренировками может повысить силу и число повторений. Это не стероид, и он работает и у женщин.',
      ),
      Tr(
        'Take 3–5 g a day, any time, with water, and keep taking it on rest days. A loading phase is optional. In the first weeks you may gain 1–2 kg from water held inside the muscles; this is normal and is not fat.',
        "Kuniga 3–5 g, istalgan vaqtda, suv bilan qabul qiling va dam kunlarida ham davom eting. Yuklash bosqichi shart emas. Dastlabki haftalarda mushaklar ichidagi suv hisobiga 1–2 kg qo'shilishi mumkin; bu normal va yog' emas.",
        'Принимайте 3–5 г в день в любое время, запивая водой, и продолжайте в дни отдыха. Фаза загрузки необязательна. В первые недели возможна прибавка 1–2 кг из-за воды внутри мышц; это нормально и это не жир.',
      ),
      Tr(
        'In healthy people at the usual dose it is considered safe in the research, but if you have kidney disease, are pregnant or breastfeeding, or are under 18, ask a doctor first.',
        "Sog'lom odamlarda odatiy dozada tadqiqotlarda xavfsiz hisoblanadi, ammo buyrak kasalligi bo'lsa, homilador yoki emizikli bo'lsangiz yoki 18 yoshgacha bo'lsangiz, avval shifokorga murojaat qiling.",
        'У здоровых людей в обычной дозе в исследованиях он считается безопасным, но при болезнях почек, беременности, кормлении грудью или возрасте до 18 лет сначала посоветуйтесь с врачом.',
      ),
    ],
    productId: 'creatine',
  ),
  NewsItem(
    id: 'whey-types',
    category: NewsCategory.supplements,
    date: DateTime(2026, 10, 7),
    minutes: 4,
    title: Tr(
      'Whey concentrate or isolate: which one to choose',
      "Whey konsentrat yoki izolyat: qaysi birini tanlash kerak",
      'Сывороточный концентрат или изолят: что выбрать',
    ),
    summary: Tr(
      'Both build muscle equally well when the protein is the same. The difference is lactose, fat and price.',
      "Oqsil bir xil bo'lsa, ikkalasi ham mushakni bir xil quradi. Farq — laktoza, yog' va narxda.",
      'При одинаковом количестве белка оба варианта одинаково работают. Разница — в лактозе, жирах и цене.',
    ),
    body: [
      Tr(
        'Whey concentrate is usually 70–80% protein and keeps some lactose and fat. Isolate is filtered further to about 90% protein, with less lactose, fat and sugar, and it costs more.',
        "Whey konsentrat odatda 70–80% oqsil bo'lib, ozroq laktoza va yog' saqlaydi. Izolyat yana filtrlanib taxminan 90% oqsilga yetadi, laktoza, yog' va shakar kamroq, narxi esa yuqoriroq.",
        'Сывороточный концентрат обычно содержит 70–80% белка и сохраняет немного лактозы и жира. Изолят фильтруется дальше до примерно 90% белка, в нём меньше лактозы, жира и сахара, и он дороже.',
      ),
      Tr(
        'Choose a concentrate if you tolerate milk and want the best price. Choose an isolate if you are cutting calories or get bloated from lactose. Neither is lactose-free, so severe intolerance needs a different product.',
        "Sutga chidamli bo'lsangiz va eng yaxshi narx kerak bo'lsa, konsentrat tanlang. Kaloriyani kamaytirayotgan bo'lsangiz yoki laktozadan shishsangiz, izolyat tanlang. Ikkalasi ham laktozasiz emas, og'ir chidamsizlikda boshqa mahsulot kerak.",
        'Выбирайте концентрат, если переносите молоко и хотите лучшую цену. Выбирайте изолят, если вы сокращаете калории или у вас вздутие от лактозы. Ни один не полностью безлактозный, при тяжёлой непереносимости нужен другой продукт.',
      ),
      Tr(
        'Look at protein per serving, a short ingredient list and independent testing. Do not pay extra for flashy labels.',
        "Porsiyadagi oqsilga, qisqa tarkib ro'yxatiga va mustaqil sinovga qarang. Yaltiroq yorliq uchun ortiqcha to'lamang.",
        'Смотрите на белок в порции, короткий состав и независимое тестирование. Не переплачивайте за яркую этикетку.',
      ),
    ],
    productId: 'whey-isolate',
  ),
  NewsItem(
    id: 'bcaa-need',
    category: NewsCategory.supplements,
    date: DateTime(2026, 9, 28),
    minutes: 3,
    title: Tr(
      'Do you really need BCAA?',
      "Sizga haqiqatan BCAA kerakmi?",
      'Нужны ли вам BCAA на самом деле?',
    ),
    summary: Tr(
      'If you eat enough protein, BCAA add little. When they can make sense.',
      "Yetarli oqsil iste'mol qilsangiz, BCAA kam foyda beradi. Qachon ma'noli bo'lishi mumkin.",
      'Если вы едите достаточно белка, BCAA почти ничего не добавляют. Когда они могут быть уместны.',
    ),
    body: [
      Tr(
        'BCAA are three amino acids, leucine, isoleucine and valine, that are already present in any complete protein: meat, eggs, dairy and whey. If your daily protein is enough, extra BCAA bring little additional benefit.',
        "BCAA — uchta aminokislota: leysin, izoleysin va valin, ular har qanday to'liq oqsilda (go'sht, tuxum, sut mahsulotlari, whey) allaqachon bor. Kunlik oqsil yetarli bo'lsa, qo'shimcha BCAA kam foyda beradi.",
        'BCAA — это три аминокислоты, лейцин, изолейцин и валин, которые уже есть в любом полноценном белке: мясе, яйцах, молочных продуктах и сывороточном протеине. Если суточного белка достаточно, дополнительные BCAA почти ничего не добавляют.',
      ),
      Tr(
        'They can be a convenient drink for long sessions, for training fasted, or when you cannot get enough protein from food. In most cases the money is better spent on regular protein foods.',
        "Ular uzoq mashg'ulotlarda, och qoringa mashqda yoki ovqatdan yetarli oqsil ololmaganda qulay ichimlik bo'lishi mumkin. Ko'p hollarda pulni oddiy oqsilli ovqatga sarflagan yaxshiroq.",
        'Они могут быть удобным напитком для долгих тренировок, тренировок натощак или когда не удаётся добрать белок из еды. В большинстве случаев деньги лучше потратить на обычные белковые продукты.',
      ),
    ],
    productId: 'bcaa',
  ),
  NewsItem(
    id: 'omega-d',
    category: NewsCategory.supplements,
    date: DateTime(2026, 9, 25),
    minutes: 4,
    title: Tr(
      'Omega-3 and vitamin D: the basics',
      "Omega-3 va D vitamini: asoslar",
      'Омега-3 и витамин D: основы',
    ),
    summary: Tr(
      'Two supplements many people consider. Who may benefit and why a test beats guessing.',
      "Ko'pchilik o'ylab ko'radigan ikki qo'shimcha. Kimga foyda berishi mumkin va nega taxmindan ko'ra tahlil yaxshi.",
      'Две добавки, о которых думают многие. Кому они могут быть полезны и почему анализ лучше догадок.',
    ),
    body: [
      Tr(
        'Omega-3 fatty acids (EPA and DHA) come mainly from oily fish. Eating fish twice a week is a good goal. A capsule can help if you rarely eat fish, but read the dose on the label and ask a doctor if you take blood thinners.',
        "Omega-3 yog' kislotalari (EPA va DHA) asosan yog'li baliqdan keladi. Haftasiga ikki marta baliq yeyish yaxshi maqsad. Baliqni kam yesangiz kapsula yordam berishi mumkin, lekin yorliqdagi dozani o'qing va qon suyultiruvchi dori qabul qilsangiz shifokorga murojaat qiling.",
        'Жирные кислоты омега-3 (ЭПК и ДГК) в основном поступают из жирной рыбы. Хорошая цель — рыба два раза в неделю. Капсулы могут помочь, если вы редко едите рыбу, но читайте дозу на этикетке и посоветуйтесь с врачом, если принимаете препараты, разжижающие кровь.',
      ),
      Tr(
        'Many people have low vitamin D in winter. The sensible way is to check your level with a blood test and follow a doctor’s advice, because taking very high doses without a reason can be harmful.',
        "Ko'p odamlarda qishda D vitamini kam bo'ladi. Aqlli yo'l — qon tahlili bilan darajani tekshirish va shifokor maslahatiga amal qilish, chunki sababsiz juda yuqori dozalar zarar qilishi mumkin.",
        'У многих зимой низкий уровень витамина D. Разумный путь — проверить его анализом крови и следовать совету врача, потому что очень высокие дозы без причины могут навредить.',
      ),
    ],
    productId: 'omega',
  ),
  // -------------------------------------------------------------------- Retseptlar
  NewsItem(
    id: 'recipe-breakfast',
    category: NewsCategory.recipes,
    date: DateTime(2026, 10, 4),
    minutes: 3,
    title: Tr(
      'A high-protein breakfast in 10 minutes',
      "10 daqiqada oqsilga boy nonushta",
      'Белковый завтрак за 10 минут',
    ),
    summary: Tr(
      'Spinach omelette with cottage cheese: about 30 g of protein, no complicated steps.',
      "Ismaloqli omlet va tvorog: taxminan 30 g oqsil, murakkab qadamlarsiz.",
      'Омлет со шпинатом и творогом: около 30 г белка, без сложных шагов.',
    ),
    body: [
      Tr(
        'Whisk 3 eggs with a pinch of salt. Wilt a handful of spinach in a non-stick pan with a teaspoon of oil, pour in the eggs and cook under a lid for 3–4 minutes.',
        "3 ta tuxumni bir chimdim tuz bilan chayqang. Yopishmaydigan tovada bir choy qoshiq yog'da bir hovuch ismaloqni so'litib, tuxumni quying va qopqoq ostida 3–4 daqiqa pishiring.",
        'Взбейте 3 яйца с щепоткой соли. Подвяльте горсть шпината на антипригарной сковороде с чайной ложкой масла, влейте яйца и готовьте под крышкой 3–4 минуты.',
      ),
      Tr(
        'Serve with 100 g of cottage cheese and a slice of whole-grain bread. Together this is roughly 30 g of protein and 400–450 kcal (approximate values).',
        "100 g tvorog va bir bo'lak to'liq donli non bilan torting. Birgalikda bu taxminan 30 g oqsil va 400–450 kkal (taxminiy qiymatlar).",
        'Подавайте со 100 г творога и ломтиком цельнозернового хлеба. Вместе это примерно 30 г белка и 400–450 ккал (приблизительные значения).',
      ),
    ],
  ),
  NewsItem(
    id: 'recipe-chicken-buckwheat',
    category: NewsCategory.recipes,
    date: DateTime(2026, 9, 29),
    minutes: 4,
    title: Tr(
      'Chicken and buckwheat lunch box',
      "Tovuq va grechkali tushlik qutisi",
      'Ланч-бокс с курицей и гречкой',
    ),
    summary: Tr(
      'The classic that works: lean protein, slow carbs and vegetables. Easy to scale for the whole week.',
      "Ishlaydigan klassika: yog'siz oqsil, sekin uglevod va sabzavot. Butun hafta uchun osongina ko'paytiriladi.",
      'Классика, которая работает: постный белок, медленные углеводы и овощи. Легко масштабируется на всю неделю.',
    ),
    body: [
      Tr(
        'Per box: 150 g chicken breast, 70 g dry buckwheat (about 180 g cooked), a large handful of vegetables such as cucumber, tomato and herbs, and a tablespoon of olive oil. Season the chicken with salt, paprika and garlic and bake for 20–25 minutes at 200 °C.',
        "Bir quti uchun: 150 g tovuq ko'kragi, 70 g quruq grechka (pishgach ~180 g), bir katta hovuch sabzavot (bodring, pomidor, ko'katlar) va bir osh qoshiq zaytun moyi. Tovuqni tuz, paprika va sarimsoq bilan ishlab, 200 °C da 20–25 daqiqa pishiring.",
        'На один контейнер: 150 г куриной грудки, 70 г сухой гречки (около 180 г готовой), большая горсть овощей, например огурец, помидор и зелень, и столовая ложка оливкового масла. Приправьте курицу солью, паприкой и чесноком и запекайте 20–25 минут при 200 °C.',
      ),
      Tr(
        'This is roughly 550–600 kcal and about 40 g of protein (approximate values). Keep it in the fridge for up to 3 days.',
        "Bu taxminan 550–600 kkal va ~40 g oqsil (taxminiy qiymatlar). Muzlatgichda 3 kungacha saqlang.",
        'Это примерно 550–600 ккал и около 40 г белка (приблизительные значения). Хранить в холодильнике до 3 дней.',
      ),
    ],
    toSubscription: true,
  ),
  NewsItem(
    id: 'recipe-pancakes',
    category: NewsCategory.recipes,
    date: DateTime(2026, 9, 26),
    minutes: 3,
    title: Tr(
      'Banana-oat protein pancakes',
      "Banan va sulidan oqsilli quymoq",
      'Банановые протеиновые панкейки',
    ),
    summary: Tr(
      'Three ingredients, one blender, and a breakfast that keeps you full until lunch.',
      "Uchta masalliq, bitta blender va tushlikkacha to'q tutadigan nonushta.",
      'Три ингредиента, один блендер и завтрак, который насыщает до обеда.',
    ),
    body: [
      Tr(
        'Blend 1 ripe banana, 2 eggs and 40 g of oats until smooth. Fry small pancakes in a non-stick pan on medium heat for about 2 minutes per side.',
        "1 ta pishgan banan, 2 ta tuxum va 40 g suli silliq bo'lguncha blenderda aralashtiring. Yopishmaydigan tovada o'rtacha olovda har tomonidan taxminan 2 daqiqa kichik quymoq qovuring.",
        'Взбейте в блендере 1 спелый банан, 2 яйца и 40 г овсяных хлопьев до однородности. Жарьте небольшие панкейки на антипригарной сковороде на среднем огне примерно по 2 минуты с каждой стороны.',
      ),
      Tr(
        'Serve with 100 g of plain yogurt and berries. About 400–450 kcal and 20–25 g of protein (approximate values). Add a scoop of protein powder to the batter for more.',
        "100 g oddiy yogurt va rezavorlar bilan torting. Taxminan 400–450 kkal va 20–25 g oqsil (taxminiy qiymatlar). Ko'proq oqsil uchun xamirga bir o'lchov protein kukuni qo'shing.",
        'Подавайте со 100 г натурального йогурта и ягодами. Около 400–450 ккал и 20–25 г белка (приблизительные значения). Для большего количества белка добавьте в тесто мерную ложку протеина.',
      ),
    ],
  ),
];
