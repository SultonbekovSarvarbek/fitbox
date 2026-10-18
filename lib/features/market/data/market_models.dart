import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/audience.dart';
import '../../../core/content/content_l10n.dart';
import '../../../core/storage/stored_list.dart';
import '../../setup/setup_profile.dart';

/// Do'kon: sog'lom ovqat yetkazib berish + sportpit.
///
/// ⚠️ DEMO: kompaniya va mahsulotlar o'ylab topilgan (haqiqiy firmalar emas).
/// TODO(backend): hamkorlar, narxlar, qoldiq va buyurtmalar serverdan; to'lov — Payme/Click.

/// 89000 → "89 000 so'm" (tilga qarab).
String formatSum(BuildContext context, int sum) {
  final code = Localizations.localeOf(context).languageCode;
  final n = NumberFormat.decimalPattern(
    code == 'en' ? 'en' : 'ru',
  ).format(sum).replaceAll(',', ' ');
  return switch (code) {
    'ru' => '$n сум',
    'en' => '$n UZS',
    _ => "$n so'm",
  };
}

// ---------------------------------------------------------------------------
// Ovqat yetkazib berish
// ---------------------------------------------------------------------------

/// Bizning oshxona: hamma uchun bitta — ratsionlarni biz o'zimiz tayyorlaymiz va kuryer yetkazadi.
/// TODO(backend/admin): ratsionlar, menyu va narxlar admin paneldan.
const kitchenName = 'Forkout Kitchen';

class MealPlanOffer {
  const MealPlanOffer({
    required this.id,
    required this.title,
    required this.tagline,
    required this.kcal,
    required this.mealsPerDay,
    required this.pricePerDay,
    required this.goals,
    required this.menu,
    this.audience = Audience.everyone,
  });

  final String id;
  final Tr title;

  /// Bir qatorli tavsif: kimga mos.
  final Tr tagline;
  final int kcal;
  final int mealsPerDay;
  final int pricePerDay;

  /// Qaysi maqsadlarga mos.
  final Set<Goal> goals;

  /// Bir kunlik menyu namunasi.
  final List<Tr> menu;

  /// Kimlar uchun: hammaga, erkaklarga yoki ayollarga.
  final Audience audience;
}

const _bf = Tr('Breakfast', 'Nonushta', 'Завтрак');

const mealPlans = <MealPlanOffer>[
  MealPlanOffer(
    id: 'slim-1200',
    title: Tr('Weight Loss', 'Vazn tushirish', 'Снижение веса'),
    tagline: Tr(
      'Smaller portions and lots of vegetables for steady weight loss',
      "Kichik porsiyalar va ko'p sabzavot — barqaror ozish uchun",
      'Небольшие порции и много овощей для стабильного снижения веса',
    ),
    kcal: 1200,
    mealsPerDay: 4,
    pricePerDay: 89000,
    goals: {Goal.loseWeight},
    menu: [
      Tr(
        'Oatmeal with berries',
        "Rezavorli suli bo'tqasi",
        'Овсянка с ягодами',
      ),
      Tr('Chicken salad', 'Tovuqli salat', 'Салат с курицей'),
      Tr(
        'Steamed fish & vegetables',
        "Bug'da pishgan baliq va sabzavot",
        'Рыба на пару с овощами',
      ),
      Tr('Greek yogurt', 'Grek yogurti', 'Греческий йогурт'),
    ],
  ),
  MealPlanOffer(
    id: 'light-1400',
    title: Tr('Light Day', 'Yengil kun', 'Лёгкий день'),
    tagline: Tr(
      'Light, vegetable-based',
      'Yengil, sabzavotli',
      'Лёгкое, на овощах',
    ),
    kcal: 1400,
    mealsPerDay: 4,
    pricePerDay: 95000,
    goals: {Goal.loseWeight, Goal.shapeBody},
    menu: [
      Tr('Green smoothie', 'Yashil smuzi', 'Зелёный смузи'),
      Tr(
        'Quinoa & avocado bowl',
        'Kinoa va avokado boul',
        'Боул с киноа и авокадо',
      ),
      Tr('Lentil soup', "Yasmiq sho'rva", 'Чечевичный суп'),
      Tr('Tofu & vegetables', 'Tofu va sabzavot', 'Тофу с овощами'),
    ],
  ),
  MealPlanOffer(
    id: 'balance-1600',
    title: Tr('Balance', 'Muvozanat', 'Баланс'),
    tagline: Tr(
      'Balanced everyday ration',
      'Muvozanatli kundalik ratsion',
      'Сбалансированный рацион на каждый день',
    ),
    kcal: 1600,
    mealsPerDay: 5,
    pricePerDay: 105000,
    goals: {Goal.loseWeight, Goal.shapeBody},
    menu: [
      Tr('Omelette with spinach', 'Ismaloqli omlet', 'Омлет со шпинатом'),
      Tr(
        'Turkey with buckwheat',
        "Grechka bilan kurka go'shti",
        'Индейка с гречкой',
      ),
      Tr(
        'Beef & vegetable soup',
        "Mol go'shtli sabzavot sho'rva",
        'Суп с говядиной и овощами',
      ),
      Tr('Cottage cheese & nuts', "Tvorog va yong'oq", 'Творог с орехами'),
      Tr('Salmon with rice', 'Guruch bilan losos', 'Лосось с рисом'),
    ],
  ),
  MealPlanOffer(
    id: 'classic-2000',
    title: Tr('Uzbek Classic', "O'zbek klassikasi", 'Узбекская классика'),
    tagline: Tr(
      'Healthy Uzbek home-style cuisine',
      "Uy uslubidagi sog'lom o'zbek taomlari",
      'Полезная узбекская кухня по-домашнему',
    ),
    kcal: 2000,
    mealsPerDay: 4,
    pricePerDay: 99000,
    goals: {Goal.shapeBody, Goal.others, Goal.muscleMass},
    menu: [
      Tr('Cottage cheese with raisins', 'Mayizli tvorog', 'Творог с изюмом'),
      Tr('Mastava (lean)', "Yog'siz mastava", 'Мастава (постная)'),
      Tr(
        'Grilled chicken & salad',
        'Grilda tovuq va salat',
        'Курица гриль с салатом',
      ),
      Tr('Fruit plate', 'Meva laganchasi', 'Фруктовая тарелка'),
    ],
  ),
  MealPlanOffer(
    id: 'mass-2500',
    title: Tr('Muscle Gain', 'Mushak qurish', 'Набор мышц'),
    tagline: Tr(
      'High-protein, for muscle gain',
      "Mushak uchun yuqori oqsilli",
      'Высокобелковое, для набора мышц',
    ),
    kcal: 2500,
    mealsPerDay: 5,
    pricePerDay: 135000,
    goals: {Goal.muscleMass, Goal.gainWeight},
    menu: [
      Tr(
        'Eggs, oats & banana',
        'Tuxum, suli va banan',
        'Яйца, овсянка и банан',
      ),
      Tr(
        'Beef steak with potatoes',
        "Kartoshka bilan mol go'shti steyk",
        'Стейк из говядины с картофелем',
      ),
      Tr('Chicken pasta', 'Tovuqli makaron', 'Паста с курицей'),
      Tr('Protein pancakes', 'Proteinli quymoq', 'Протеиновые панкейки'),
      Tr('Cottage cheese & honey', 'Tvorog va asal', 'Творог с мёдом'),
    ],
  ),
  MealPlanOffer(
    id: 'bulk-3000',
    title: Tr('Max Mass', 'Maksimal massa', 'Максимум массы'),
    tagline: Tr(
      'Maximum calories for gaining weight',
      "Vazn olish uchun maksimal kaloriya",
      'Максимум калорий для набора веса',
    ),
    kcal: 3000,
    mealsPerDay: 6,
    pricePerDay: 159000,
    goals: {Goal.gainWeight},
    menu: [
      _bf,
      Tr(
        'Plov with beef (lean)',
        "Yog'siz mol go'shtli osh",
        'Плов с постной говядиной',
      ),
      Tr('Chicken & rice bowl', 'Tovuq va guruch', 'Курица с рисом'),
      Tr('Mass shake', 'Massa kokteyli', 'Коктейль для массы'),
      Tr('Salmon & quinoa', 'Losos va kinoa', 'Лосось с киноа'),
      Tr('Nuts & dried fruits', "Yong'oq va quruq meva", 'Орехи и сухофрукты'),
    ],
  ),
  MealPlanOffer(
    id: 'she-1500',
    title: Tr('Slim & Fit', "Ozg'in va tarang", 'Стройность'),
    tagline: Tr(
      'Light and balanced, for women who want to slim down',
      "Yengil va muvozanatli, ozmoqchi bo'lgan ayollar uchun",
      'Лёгкое и сбалансированное, для женщин, которые хотят похудеть',
    ),
    kcal: 1500,
    mealsPerDay: 4,
    pricePerDay: 92000,
    goals: {Goal.loseWeight, Goal.shapeBody},
    audience: Audience.women,
    menu: [
      Tr(
        'Cottage cheese with berries',
        'Tvorog va rezavorlar',
        'Творог с ягодами',
      ),
      Tr(
        'Chicken breast with quinoa',
        "Kinoa bilan tovuq ko'kragi",
        'Куриная грудка с киноа',
      ),
      Tr('Vegetable cream soup', "Sabzavotli krem-sho'rva", 'Овощной крем-суп'),
      Tr(
        'Baked fish with salad',
        'Salat bilan pishirilgan baliq',
        'Запечённая рыба с салатом',
      ),
    ],
  ),
  MealPlanOffer(
    id: 'she-1900',
    title: Tr('Energy & Shape', 'Energiya va shakl', 'Энергия и форма'),
    tagline: Tr(
      'For active women: enough energy for training',
      "Faol ayollar uchun: mashg'ulotga yetarli energiya",
      'Для активных женщин: достаточно энергии для тренировок',
    ),
    kcal: 1900,
    mealsPerDay: 5,
    pricePerDay: 112000,
    goals: {Goal.shapeBody, Goal.muscleMass, Goal.others},
    audience: Audience.women,
    menu: [
      Tr('Omelette with vegetables', 'Sabzavotli omlet', 'Омлет с овощами'),
      Tr(
        'Turkey with buckwheat',
        "Grechka bilan kurka go'shti",
        'Индейка с гречкой',
      ),
      Tr('Lentil soup', "Yasmiq sho'rva", 'Чечевичный суп'),
      Tr(
        'Greek yogurt with nuts and fruit',
        "Grek yogurti, yong'oq va meva",
        'Греческий йогурт с орехами и фруктами',
      ),
      Tr('Salmon with rice', 'Guruch bilan losos', 'Лосось с рисом'),
    ],
  ),
  MealPlanOffer(
    id: 'he-2400',
    title: Tr('Strong & Fit', 'Kuch va shakl', 'Сила и форма'),
    tagline: Tr(
      'Balanced, for men who train regularly',
      "Muvozanatli, muntazam mashq qiladigan erkaklar uchun",
      'Сбалансированное, для мужчин, которые регулярно тренируются',
    ),
    kcal: 2400,
    mealsPerDay: 4,
    pricePerDay: 118000,
    goals: {Goal.shapeBody, Goal.others, Goal.muscleMass},
    audience: Audience.men,
    menu: [
      Tr('Eggs and oatmeal', 'Tuxum va suli bo\'tqasi', 'Яйца и овсянка'),
      Tr(
        'Beef with potatoes and salad',
        "Kartoshka va salat bilan mol go'shti",
        'Говядина с картофелем и салатом',
      ),
      Tr(
        'Lean chicken plov',
        "Yog'siz tovuqli osh",
        'Плов с курицей (постный)',
      ),
      Tr('Cottage cheese with honey', 'Tvorog va asal', 'Творог с мёдом'),
    ],
  ),
  MealPlanOffer(
    id: 'he-2900',
    title: Tr('Power Mass', 'Kuchli massa', 'Мощный набор'),
    tagline: Tr(
      'High-protein, for building muscle',
      "Yuqori oqsilli, mushak qurish uchun",
      'Высокобелковое, для набора мышечной массы',
    ),
    kcal: 2900,
    mealsPerDay: 5,
    pricePerDay: 152000,
    goals: {Goal.muscleMass, Goal.gainWeight},
    audience: Audience.men,
    menu: [
      Tr(
        'Omelette, oats and banana',
        'Omlet, suli va banan',
        'Омлет, овсянка и банан',
      ),
      Tr(
        'Beef steak with rice',
        "Guruch bilan mol go'shti steyk",
        'Стейк из говядины с рисом',
      ),
      Tr('Chicken pasta', 'Tovuqli makaron', 'Паста с курицей'),
      Tr('Protein pancakes', 'Proteinli quymoq', 'Протеиновые панкейки'),
      Tr(
        'Salmon with potatoes',
        'Kartoshka bilan losos',
        'Лосось с картофелем',
      ),
    ],
  ),
];

/// Avvalgi versiyada saqlangan obunalar eski id bilan bo'lishi mumkin.
const _legacyPlanIds = {
  'fitbox-1200': 'slim-1200',
  'gb-1400': 'light-1400',
  'fitbox-1600': 'balance-1600',
  'bf-2000': 'classic-2000',
  'pk-2500': 'mass-2500',
  'pk-3000': 'bulk-3000',
};

MealPlanOffer? mealPlanById(String id) {
  final real = _legacyPlanIds[id] ?? id;
  return mealPlans.where((p) => p.id == real).firstOrNull;
}

/// Tavsiya: kaloriyasi me'yorga yaqin + maqsadga mos ratsionlar (eng yaxshisi birinchi).
/// [gender] berilsa — faqat shu jinsga mos (yoki hamma uchun) ratsionlar, aynan shu jins
/// uchun yaratilgani esa teng sharoitda ustun turadi.
List<MealPlanOffer> recommendPlans({
  required int targetKcal,
  required Goal goal,
  Gender? gender,
  List<MealPlanOffer> plans = mealPlans,
  int take = 3,
}) {
  final pool = [
    for (final p in plans)
      if (gender == null || audienceFitsGender(p.audience, gender)) p,
  ];

  double score(MealPlanOffer p) {
    final diff = (p.kcal - targetKcal).abs() / targetKcal; // 0 — aynan mos
    // Kunlik me'yor maqsadni allaqachon hisobga oladi (ozish −500, massa +250...),
    // shuning uchun maqsadga mos kelmaslik faqat kichik jarima: kaloriya asosiy mezon.
    final goalPenalty = p.goals.contains(goal) ? 0.0 : 0.1;
    // Teng sharoitda aynan shu jins uchun yaratilgan ratsion yaxshiroq.
    final specific = gender != null && audienceIsSpecificTo(p.audience, gender)
        ? 0.02
        : 0.0;
    return diff + goalPenalty - specific;
  }

  final sorted = [...pool]..sort((a, b) => score(a).compareTo(score(b)));
  return sorted.take(take).toList();
}

// ---------------------------------------------------------------------------
// Sportpit
// ---------------------------------------------------------------------------

enum ProductCategory {
  protein,
  creatine,
  gainer,
  aminos,
  vitamins,
  wellness,
  bars,
}

const categoryNames = <ProductCategory, Tr>{
  ProductCategory.protein: Tr('Protein', 'Protein', 'Протеин'),
  ProductCategory.creatine: Tr('Creatine', 'Kreatin', 'Креатин'),
  ProductCategory.gainer: Tr('Gainer', 'Gainer', 'Гейнер'),
  ProductCategory.aminos: Tr(
    'BCAA / Amino',
    'BCAA / Aminokislota',
    'BCAA / Аминокислоты',
  ),
  ProductCategory.vitamins: Tr('Vitamins', 'Vitaminlar', 'Витамины'),
  ProductCategory.wellness: Tr('Wellness', 'Salomatlik', 'Здоровье'),
  ProductCategory.bars: Tr('Bars', 'Batonchiklar', 'Батончики'),
};

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.rating,
    required this.size,
    required this.description,
    required this.goals,
    this.image,
    this.audience = Audience.everyone,
  });

  final String id;
  final Tr name;
  final String brand;
  final ProductCategory category;
  final int price;
  final double rating;

  /// "2.27 kg · 75 porsiya"
  final Tr size;
  final Tr description;
  final Set<Goal> goals;

  /// Mahsulot rasmi (oq fonli qadoq surati); yo'q bo'lsa — kategoriya ikonkasi.
  final String? image;

  /// Kimlar uchun: hammaga, erkaklarga yoki ayollarga.
  final Audience audience;
}

const products = <Product>[
  Product(
    id: 'whey-choco',
    name: Tr(
      'Whey Protein · Chocolate',
      'Whey protein · Shokolad',
      'Сывороточный протеин · Шоколад',
    ),
    brand: 'IronLab',
    category: ProductCategory.protein,
    price: 529000,
    rating: 4.8,
    size: Tr(
      '2.27 kg · 75 servings',
      '2.27 kg · 75 porsiya',
      '2,27 кг · 75 порций',
    ),
    description: Tr(
      '24 g protein per serving. After training or between meals.',
      "Har porsiyada 24 g oqsil. Mashg'ulotdan keyin yoki ovqatlar orasida.",
      '24 г белка в порции. После тренировки или между приёмами пищи.',
    ),
    goals: {Goal.muscleMass, Goal.shapeBody, Goal.gainWeight},
  ),
  Product(
    id: 'whey-isolate',
    name: Tr(
      'Gold Standard 100% Isolate · Chocolate Bliss',
      'Gold Standard 100% Isolate · Shokolad',
      'Gold Standard 100% Isolate · Шоколад',
    ),
    brand: 'Optimum Nutrition',
    category: ProductCategory.protein,
    price: 899000,
    rating: 4.9,
    size: Tr(
      '1.36 kg · 44 servings',
      '1.36 kg · 44 porsiya',
      '1,36 кг · 44 порции',
    ),
    description: Tr(
      '25 g protein and 5.5 g BCAA per serving, ultra-filtered whey isolate. Almost no fat or sugar — good for cutting and recovery.',
      "Har porsiyada 25 g oqsil va 5.5 g BCAA, ultra-filtrlangan whey izolyat. Yog' va shakar deyarli yo'q — quritish va tiklanish uchun yaxshi.",
      '25 г белка и 5,5 г BCAA в порции, ультрафильтрованный изолят. Почти без жиров и сахара — для сушки и восстановления.',
    ),
    goals: {Goal.loseWeight, Goal.shapeBody, Goal.muscleMass},
    image: 'assets/images/products/whey-isolate.webp',
  ),
  Product(
    id: 'creatine',
    name: Tr(
      'Creatine Monohydrate',
      'Kreatin monogidrat',
      'Креатин моногидрат',
    ),
    brand: 'IronLab',
    category: ProductCategory.creatine,
    price: 189000,
    rating: 4.9,
    size: Tr('300 g · 60 servings', '300 g · 60 porsiya', '300 г · 60 порций'),
    description: Tr(
      '5 g a day. The most researched supplement for strength and muscle.',
      "Kuniga 5 g. Kuch va mushak uchun eng ko'p o'rganilgan qo'shimcha.",
      '5 г в день. Самая изученная добавка для силы и мышц.',
    ),
    goals: {Goal.muscleMass, Goal.gainWeight, Goal.shapeBody},
  ),
  Product(
    id: 'gainer',
    name: Tr('Mass Gainer', 'Mass Gainer', 'Гейнер для массы'),
    brand: 'NutriPro',
    category: ProductCategory.gainer,
    price: 459000,
    rating: 4.6,
    size: Tr('3 kg · 20 servings', '3 kg · 20 porsiya', '3 кг · 20 порций'),
    description: Tr(
      '~750 kcal per shake. For those who struggle to gain weight.',
      "Bir kokteylda ~750 kkal. Vazn olishi qiyin bo'lganlar uchun.",
      '~750 ккал в коктейле. Для тех, кому сложно набрать вес.',
    ),
    goals: {Goal.gainWeight},
  ),
  Product(
    id: 'bcaa',
    name: Tr('BCAA 2:1:1', 'BCAA 2:1:1', 'BCAA 2:1:1'),
    brand: 'FitFuel',
    category: ProductCategory.aminos,
    price: 239000,
    rating: 4.4,
    size: Tr('400 g · 40 servings', '400 g · 40 porsiya', '400 г · 40 порций'),
    description: Tr(
      'During long workouts. Optional if you eat enough protein.',
      "Uzoq mashg'ulot paytida. Oqsil yetarli bo'lsa — shart emas.",
      'Во время долгих тренировок. Не обязателен при достатке белка.',
    ),
    goals: {Goal.muscleMass, Goal.loseWeight},
  ),
  Product(
    id: 'omega',
    name: Tr('Omega-3', 'Omega-3', 'Омега-3'),
    brand: 'FitFuel',
    category: ProductCategory.vitamins,
    price: 149000,
    rating: 4.7,
    size: Tr('120 capsules', '120 kapsula', '120 капсул'),
    description: Tr(
      'Heart and joint health.',
      "Yurak va bo'g'imlar salomatligi uchun.",
      'Для сердца и суставов.',
    ),
    goals: {
      Goal.loseWeight,
      Goal.shapeBody,
      Goal.muscleMass,
      Goal.gainWeight,
      Goal.others,
    },
  ),
  Product(
    id: 'multi',
    name: Tr(
      'Multivitamin Sport',
      'Multivitamin Sport',
      'Мультивитамины Sport',
    ),
    brand: 'NutriPro',
    category: ProductCategory.vitamins,
    price: 169000,
    rating: 4.5,
    size: Tr('90 tablets', '90 tabletka', '90 таблеток'),
    description: Tr(
      'Covers micronutrient gaps during intense training.',
      "Jadal mashg'ulotlarda mikroelementlar kamchiligini to'ldiradi.",
      'Восполняет дефицит микроэлементов при интенсивных тренировках.',
    ),
    goals: {
      Goal.loseWeight,
      Goal.shapeBody,
      Goal.muscleMass,
      Goal.gainWeight,
      Goal.others,
    },
  ),
  Product(
    id: 'bar',
    name: Tr(
      'Protein Bar · 12 pcs',
      'Proteinli baton · 12 dona',
      'Протеиновый батончик · 12 шт.',
    ),
    brand: 'IronLab',
    category: ProductCategory.bars,
    price: 199000,
    rating: 4.6,
    size: Tr(
      '12 × 60 g · 20 g protein',
      '12 × 60 g · 20 g oqsil',
      '12 × 60 г · 20 г белка',
    ),
    description: Tr(
      'A healthy snack on the go.',
      "Yo'lda sog'lom gazak.",
      'Полезный перекус в дороге.',
    ),
    goals: {Goal.loseWeight, Goal.shapeBody, Goal.muscleMass},
  ),
  // ------------------------------------------------------------------ Ayollarga
  Product(
    id: 'w-whey-lite',
    name: Tr(
      'Whey Lite for Women · Vanilla',
      'Ayollar uchun Whey Lite · Vanil',
      'Whey Lite для женщин · Ваниль',
    ),
    brand: 'FitFuel',
    category: ProductCategory.protein,
    price: 349000,
    rating: 4.7,
    size: Tr('900 g · 36 servings', '900 g · 36 porsiya', '900 г · 36 порций'),
    description: Tr(
      '20 g of protein and about 100 kcal per serving. A light shake for slimming and toning.',
      "Porsiyada 20 g oqsil va ~100 kkal. Ozish va qomatni shakllantirish uchun yengil kokteyl.",
      '20 г белка и около 100 ккал в порции. Лёгкий коктейль для похудения и тонуса.',
    ),
    goals: {Goal.loseWeight, Goal.shapeBody},
    audience: Audience.women,
  ),
  Product(
    id: 'w-multi',
    name: Tr(
      'Multivitamin for Women',
      'Ayollar uchun multivitamin',
      'Мультивитамины для женщин',
    ),
    brand: 'NutriPro',
    category: ProductCategory.vitamins,
    price: 179000,
    rating: 4.6,
    size: Tr('60 tablets', '60 tabletka', '60 таблеток'),
    description: Tr(
      'Vitamins and minerals for active women, including folate and vitamin D.',
      "Faol ayollar uchun vitamin va minerallar, jumladan foliy kislotasi va D vitamini.",
      'Витамины и минералы для активных женщин, в том числе фолиевая кислота и витамин D.',
    ),
    goals: {
      Goal.loseWeight,
      Goal.shapeBody,
      Goal.muscleMass,
      Goal.gainWeight,
      Goal.others,
    },
    audience: Audience.women,
  ),
  Product(
    id: 'w-iron',
    name: Tr('Iron + Vitamin C', 'Temir + C vitamini', 'Железо + витамин C'),
    brand: 'NutriPro',
    category: ProductCategory.vitamins,
    price: 129000,
    rating: 4.5,
    size: Tr('60 capsules', '60 kapsula', '60 капсул'),
    description: Tr(
      'Iron with vitamin C for better absorption. Take it only if a doctor found low iron.',
      "Yaxshiroq so'rilishi uchun C vitamini bilan temir. Faqat shifokor temir kamligini aniqlagan bo'lsa qabul qiling.",
      'Железо с витамином C для лучшего усвоения. Принимайте, только если врач выявил его нехватку.',
    ),
    goals: {Goal.loseWeight, Goal.shapeBody, Goal.others},
    audience: Audience.women,
  ),
  Product(
    id: 'w-collagen',
    name: Tr(
      'Collagen Peptides · Berry',
      'Kollagen peptidlari · Rezavor',
      'Коллагеновые пептиды · Ягоды',
    ),
    brand: 'FitFuel',
    category: ProductCategory.wellness,
    price: 259000,
    rating: 4.5,
    size: Tr('300 g · 30 servings', '300 g · 30 porsiya', '300 г · 30 порций'),
    description: Tr(
      'Collagen peptides that may support skin, nails and joints. Works best with vitamin C and regular training.',
      "Teri, tirnoq va bo'g'imlarni qo'llab-quvvatlashi mumkin bo'lgan kollagen peptidlari. C vitamini va muntazam mashq bilan yaxshiroq ishlaydi.",
      'Коллагеновые пептиды, которые могут поддерживать кожу, ногти и суставы. Лучше работают вместе с витамином C и регулярными тренировками.',
    ),
    goals: {Goal.shapeBody, Goal.loseWeight, Goal.others},
    audience: Audience.women,
  ),
  // ---------------------------------------------------------------- Erkaklarga
  Product(
    id: 'm-whey-power',
    name: Tr(
      'Whey Power for Men · Chocolate',
      'Erkaklar uchun Whey Power · Shokolad',
      'Whey Power для мужчин · Шоколад',
    ),
    brand: 'IronLab',
    category: ProductCategory.protein,
    price: 399000,
    rating: 4.6,
    size: Tr('2 kg · 62 servings', '2 kg · 62 porsiya', '2 кг · 62 порции'),
    description: Tr(
      '28 g of protein per serving. For building muscle after training.',
      "Porsiyada 28 g oqsil. Mashg'ulotdan keyin mushak qurish uchun.",
      '28 г белка в порции. Для набора мышечной массы после тренировки.',
    ),
    goals: {Goal.muscleMass, Goal.gainWeight},
    audience: Audience.men,
  ),
  Product(
    id: 'm-multi',
    name: Tr(
      'Multivitamin for Men',
      'Erkaklar uchun multivitamin',
      'Мультивитамины для мужчин',
    ),
    brand: 'NutriPro',
    category: ProductCategory.vitamins,
    price: 179000,
    rating: 4.6,
    size: Tr('60 tablets', '60 tabletka', '60 таблеток'),
    description: Tr(
      'Vitamins and minerals for active men, with zinc and magnesium.',
      "Faol erkaklar uchun vitamin va minerallar, rux va magniy bilan.",
      'Витамины и минералы для активных мужчин, с цинком и магнием.',
    ),
    goals: {
      Goal.loseWeight,
      Goal.shapeBody,
      Goal.muscleMass,
      Goal.gainWeight,
      Goal.others,
    },
    audience: Audience.men,
  ),
  Product(
    id: 'm-zma',
    name: Tr(
      'Zinc + Magnesium + B6',
      'Rux + Magniy + B6',
      'Цинк + Магний + B6',
    ),
    brand: 'IronLab',
    category: ProductCategory.wellness,
    price: 159000,
    rating: 4.5,
    size: Tr('90 capsules', '90 kapsula', '90 капсул'),
    description: Tr(
      'Minerals for recovery and sleep after heavy training.',
      "Og'ir mashg'ulotdan keyin tiklanish va uyqu uchun minerallar.",
      'Минералы для восстановления и сна после тяжёлых тренировок.',
    ),
    goals: {Goal.muscleMass, Goal.gainWeight, Goal.shapeBody},
    audience: Audience.men,
  ),
];

Product productById(String id) => products.firstWhere((p) => p.id == id);

/// Maqsadga mos mahsulotlar. [gender] berilsa — faqat shu jinsga mos (yoki hamma uchun)
/// mahsulotlar; aynan shu jins uchun yaratilganiga reytingga kichik ustama beriladi, shunda
/// ular ko'rinadi, lekin asosiy mahsulotlar (protein, kreatin) ularning orqasida qolmaydi.
List<Product> recommendProducts(Goal goal, {Gender? gender, int take = 4}) {
  final list = [
    for (final p in products)
      if (p.goals.contains(goal) &&
          (gender == null || audienceFitsGender(p.audience, gender)))
        p,
  ];
  double score(Product p) =>
      p.rating +
      (gender != null && audienceIsSpecificTo(p.audience, gender) ? 0.3 : 0.0);
  list.sort((a, b) => score(b).compareTo(score(a)));
  return list.take(take).toList();
}

// ---------------------------------------------------------------------------
// Savat va buyurtmalar
// ---------------------------------------------------------------------------

/// Savat: mahsulot id → soni.
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, int>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<Map<String, int>> {
  CartNotifier() : super(const {});

  void add(String id) => state = {...state, id: (state[id] ?? 0) + 1};

  void remove(String id) {
    final n = (state[id] ?? 0) - 1;
    state = n <= 0 ? ({...state}..remove(id)) : {...state, id: n};
  }

  void clear() => state = const {};
}

final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).values.fold(0, (s, n) => s + n),
);

final cartTotalProvider = Provider<int>(
  (ref) => ref
      .watch(cartProvider)
      .entries
      .fold(0, (s, e) => s + productById(e.key).price * e.value),
);

enum PaymentMethod { payme, click, cash }

class Order {
  const Order({
    required this.id,
    required this.date,
    required this.title,
    required this.total,
    required this.payment,
    required this.address,
  });

  final String id;
  final DateTime date;
  final String title;
  final int total;
  final PaymentMethod payment;
  final String address;

  Map<String, Object?> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'title': title,
    'total': total,
    'payment': payment.name,
    'address': address,
  };

  static Order fromJson(Map<String, Object?> j) => Order(
    id: j['id'] as String,
    date: DateTime.parse(j['date'] as String),
    title: j['title'] as String,
    total: (j['total'] as num).toInt(),
    payment: PaymentMethod.values.firstWhere(
      (p) => p.name == j['payment'],
      orElse: () => PaymentMethod.cash,
    ),
    address: j['address'] as String? ?? '',
  );
}

/// Buyurtmalar tarixi (demo — hech qayerga yuborilmaydi).
final ordersProvider = StateNotifierProvider<OrdersNotifier, List<Order>>(
  (ref) => OrdersNotifier(ref),
);

class OrdersNotifier extends StoredList<Order> {
  OrdersNotifier(Ref ref) : super(ref, 'orders');

  @override
  Order decode(Map<String, Object?> json) => Order.fromJson(json);
  @override
  Map<String, Object?> encode(Order item) => item.toJson();

  void add(Order o) => save([o, ...state]);
}
