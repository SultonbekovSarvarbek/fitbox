import '../../../core/content/content_l10n.dart';

/// Mahsulot sahifasi uchun: nima uchun, qanday qabul qilinadi, tarkibi, qarshi ko'rsatmalar.
///
/// ⚠️ DEMO: mahsulotlar namunaviy. Haqiqiy mahsulotlar uchun matnlar ishlab chiqaruvchi
/// ko'rsatmasidan olinadi.
/// TODO(backend/cms): kontent admin paneldan, har bir tilda.
class ProductInfo {
  const ProductInfo({
    required this.benefits,
    required this.howToUse,
    required this.facts,
    required this.contraindications,
    this.storage,
  });

  /// Nima uchun kerak.
  final List<Tr> benefits;

  /// Qabul qilish usuli (har bir band alohida qator).
  final List<Tr> howToUse;

  /// Tarkib / ozuqaviy qiymat: (nomi, qiymati).
  final List<(Tr, Tr)> facts;

  /// Kimga mumkin emas yoki shifokor bilan maslahat kerak.
  final List<Tr> contraindications;
  final Tr? storage;
}

/// Hamma mahsulotga tegishli ogohlantirish.
const supplementDisclaimer = Tr(
  'This is a dietary supplement, not a medicine, and not a substitute for a varied diet. Do not exceed the recommended dose. Keep out of reach of children. If you have a chronic condition, take medication, are pregnant or breastfeeding, or are under 18, talk to a doctor before use.',
  "Bu biologik faol qo'shimcha, dori emas va xilma-xil ovqatlanishning o'rnini bosmaydi. Tavsiya etilgan dozadan oshirmang. Bolalardan uzoq saqlang. Surunkali kasallik, dori qabul qilish, homiladorlik, emizish yoki 18 yoshgacha bo'lsangiz — qabul qilishdan oldin shifokor bilan maslahatlashing.",
  'Это биологически активная добавка, а не лекарство, и она не заменяет разнообразное питание. Не превышайте рекомендуемую дозу. Хранить в недоступном для детей месте. При хронических заболеваниях, приёме лекарств, беременности, кормлении грудью или возрасте до 18 лет проконсультируйтесь с врачом.',
);

const _milk = Tr(
  'Milk protein allergy or individual intolerance',
  "Sut oqsiliga allergiya yoki individual chidamsizlik",
  'Аллергия на молочный белок или индивидуальная непереносимость',
);
const _kidney = Tr(
  'Kidney disease — only after a doctor’s approval',
  "Buyrak kasalliklari — faqat shifokor ruxsati bilan",
  'Заболевания почек — только с разрешения врача',
);
const _special = Tr(
  'Pregnancy, breastfeeding and under 18 — only after talking to a doctor',
  "Homiladorlik, emizish va 18 yoshgacha — faqat shifokor bilan maslahatdan keyin",
  'Беременность, кормление грудью и возраст до 18 лет — только после консультации с врачом',
);
const _dry = Tr(
  'Store in a cool, dry place away from sunlight. Close the pack tightly after use.',
  "Salqin, quruq joyda, quyoshdan uzoqda saqlang. Ishlatgandan keyin qadoqni mahkam yoping.",
  'Хранить в прохладном сухом месте, вдали от солнца. После использования плотно закрывать упаковку.',
);

const productInfo = <String, ProductInfo>{
  'whey-choco': ProductInfo(
    benefits: [
      Tr(
        'Helps you reach your daily protein target when food alone is not enough',
        "Faqat ovqat yetmaganda kunlik oqsil me'yorini to'ldirishga yordam beradi",
        'Помогает добрать суточную норму белка, когда одной еды не хватает',
      ),
      Tr(
        'Convenient after training or between meals',
        "Mashg'ulotdan keyin yoki ovqatlar orasida qulay",
        'Удобен после тренировки или между приёмами пищи',
      ),
      Tr(
        'Supports muscle recovery together with training and a balanced diet',
        "Mashg'ulot va muvozanatli ovqatlanish bilan birga mushaklar tiklanishini qo'llab-quvvatlaydi",
        'Поддерживает восстановление мышц вместе с тренировками и сбалансированным питанием',
      ),
    ],
    howToUse: [
      Tr(
        'Mix 1 serving (about 30 g) with 200–250 ml of water or milk.',
        "1 porsiyani (taxminan 30 g) 200–250 ml suv yoki sutga aralashtiring.",
        'Размешайте 1 порцию (около 30 г) в 200–250 мл воды или молока.',
      ),
      Tr(
        'Take 1–2 times a day: after training or between meals.',
        "Kuniga 1–2 marta: mashg'ulotdan keyin yoki ovqatlar orasida.",
        'Принимайте 1–2 раза в день: после тренировки или между приёмами пищи.',
      ),
      Tr(
        'Count it towards your daily protein, do not add it on top of an already high intake.',
        "Uni kunlik oqsilga qo'shib hisoblang, allaqachon yuqori iste'molga ustiga qo'shmang.",
        'Учитывайте его в суточной норме белка, не добавляйте сверх уже высокого потребления.',
      ),
    ],
    facts: [
      (Tr('Serving', 'Porsiya', 'Порция'), Tr('~30 g', '~30 g', '~30 г')),
      (
        Tr('Protein per serving', 'Porsiyada oqsil', 'Белка в порции'),
        Tr('24 g', '24 g', '24 г'),
      ),
      (
        Tr('Servings per pack', 'Qadoqda porsiya', 'Порций в упаковке'),
        Tr('75', '75', '75'),
      ),
      (
        Tr('Type', 'Turi', 'Тип'),
        Tr('Whey protein', 'Whey oqsil', 'Сывороточный протеин'),
      ),
    ],
    contraindications: [
      _milk,
      Tr(
        'Lactose intolerance — whey concentrate contains some lactose; an isolate may suit better',
        "Laktoza chidamsizligi — konsentratda laktoza bor; izolyat mosroq bo'lishi mumkin",
        'Непереносимость лактозы — в концентрате есть лактоза; лучше подойдёт изолят',
      ),
      _kidney,
      _special,
    ],
    storage: _dry,
  ),
  'whey-isolate': ProductInfo(
    benefits: [
      Tr(
        'High protein with almost no fat or sugar — fits a calorie deficit',
        "Yog' va shakar deyarli yo'q, oqsil ko'p — kaloriya tanqisligiga mos",
        'Много белка почти без жиров и сахара — подходит при дефиците калорий',
      ),
      Tr(
        '5.5 g of BCAA per serving',
        "Porsiyada 5.5 g BCAA",
        '5,5 г BCAA в порции',
      ),
      Tr(
        'Ultra-filtered isolate: lower in lactose than a concentrate',
        "Ultra-filtrlangan izolyat: konsentratga qaraganda laktoza kamroq",
        'Ультрафильтрованный изолят: лактозы меньше, чем в концентрате',
      ),
    ],
    howToUse: [
      Tr(
        'Mix 1 serving (about 31 g) with 200–250 ml of cold water or milk.',
        "1 porsiyani (taxminan 31 g) 200–250 ml sovuq suv yoki sutga aralashtiring.",
        'Размешайте 1 порцию (около 31 г) в 200–250 мл холодной воды или молока.',
      ),
      Tr(
        'Take 1–2 times a day: after training or as a protein snack.',
        "Kuniga 1–2 marta: mashg'ulotdan keyin yoki oqsilli gazak sifatida.",
        'Принимайте 1–2 раза в день: после тренировки или как белковый перекус.',
      ),
    ],
    facts: [
      (Tr('Serving', 'Porsiya', 'Порция'), Tr('~31 g', '~31 g', '~31 г')),
      (
        Tr('Protein per serving', 'Porsiyada oqsil', 'Белка в порции'),
        Tr('25 g', '25 g', '25 г'),
      ),
      (
        Tr('BCAA per serving', 'Porsiyada BCAA', 'BCAA в порции'),
        Tr('5.5 g', '5.5 g', '5,5 г'),
      ),
      (
        Tr('Servings per pack', 'Qadoqda porsiya', 'Порций в упаковке'),
        Tr('44', '44', '44'),
      ),
      (
        Tr('Type', 'Turi', 'Тип'),
        Tr('Whey isolate', 'Whey izolyat', 'Сывороточный изолят'),
      ),
    ],
    contraindications: [
      _milk,
      Tr(
        'Severe lactose intolerance — an isolate is low in lactose but not lactose-free',
        "Og'ir laktoza chidamsizligi — izolyatda laktoza kam, lekin butunlay yo'q emas",
        'Тяжёлая непереносимость лактозы — в изоляте лактозы мало, но она не отсутствует полностью',
      ),
      _kidney,
      _special,
    ],
    storage: _dry,
  ),
  'creatine': ProductInfo(
    benefits: [
      Tr(
        'One of the most studied supplements for strength and short intense efforts',
        "Kuch va qisqa jadal harakatlar uchun eng ko'p o'rganilgan qo'shimchalardan biri",
        'Одна из самых изученных добавок для силы и коротких интенсивных нагрузок',
      ),
      Tr(
        'Works with regular strength training — without training the effect is small',
        "Muntazam kuch mashqlari bilan ishlaydi — mashqsiz ta'siri kam",
        'Работает вместе с регулярными силовыми тренировками — без тренировок эффект небольшой',
      ),
    ],
    howToUse: [
      Tr(
        'Take 5 g (1 level scoop) once a day, every day — including rest days.',
        "Kuniga bir marta 5 g (1 tekis o'lchov qoshiq), har kuni — dam olish kunlarida ham.",
        'Принимайте 5 г (1 ровная мерная ложка) раз в день, каждый день — в том числе в дни отдыха.',
      ),
      Tr(
        'Dissolve in water or juice. The time of day does not matter — consistency does.',
        "Suv yoki sharbatda eritib iching. Kunning vaqti muhim emas — muntazamlik muhim.",
        'Растворите в воде или соке. Время суток не важно — важна регулярность.',
      ),
      Tr(
        'Drink enough water during the day. A loading phase is not required.',
        "Kun davomida yetarli suv iching. Yuklash bosqichi shart emas.",
        'Пейте достаточно воды в течение дня. Фаза загрузки не обязательна.',
      ),
    ],
    facts: [
      (Tr('Serving', 'Porsiya', 'Порция'), Tr('5 g', '5 g', '5 г')),
      (
        Tr('Servings per pack', 'Qadoqda porsiya', 'Порций в упаковке'),
        Tr('60', '60', '60'),
      ),
      (
        Tr('Form', 'Shakli', 'Форма'),
        Tr('Monohydrate', 'Monogidrat', 'Моногидрат'),
      ),
    ],
    contraindications: [
      _kidney,
      Tr(
        'Individual intolerance',
        "Individual chidamsizlik",
        'Индивидуальная непереносимость',
      ),
      Tr(
        'You may notice 1–2 kg of body weight from water retention at the start — this is normal',
        "Boshida suv ushlanishi hisobiga 1–2 kg vazn qo'shilishi mumkin — bu normal",
        'В начале приёма возможна прибавка 1–2 кг из-за задержки воды — это нормально',
      ),
      _special,
    ],
    storage: _dry,
  ),
  'gainer': ProductInfo(
    benefits: [
      Tr(
        'About 750 kcal per serving — an easy way to add calories',
        "Bir porsiyada ~750 kkal — kaloriyani qo'shishning oson yo'li",
        'Около 750 ккал в порции — простой способ добавить калории',
      ),
      Tr(
        'Useful if you struggle to gain weight with regular food',
        "Oddiy ovqat bilan vazn olish qiyin bo'lsa foydali",
        'Полезен, если сложно набрать вес обычной едой',
      ),
    ],
    howToUse: [
      Tr(
        'Mix 1 serving (about 150 g) with 400–500 ml of water or milk.',
        "1 porsiyani (taxminan 150 g) 400–500 ml suv yoki sutga aralashtiring.",
        'Размешайте 1 порцию (около 150 г) в 400–500 мл воды или молока.',
      ),
      Tr(
        'Take once a day between meals or after training. Start with half a serving to check tolerance.',
        "Kuniga bir marta ovqatlar orasida yoki mashg'ulotdan keyin. Chidamliligini tekshirish uchun yarim porsiyadan boshlang.",
        'Принимайте раз в день между едой или после тренировки. Начните с половины порции, чтобы проверить переносимость.',
      ),
      Tr(
        'Not for weight loss: it is a high-calorie product.',
        "Ozish uchun emas: bu yuqori kaloriyali mahsulot.",
        'Не для похудения: это высококалорийный продукт.',
      ),
    ],
    facts: [
      (Tr('Serving', 'Porsiya', 'Порция'), Tr('~150 g', '~150 g', '~150 г')),
      (
        Tr('Energy per serving', 'Porsiyada energiya', 'Энергия в порции'),
        Tr('~750 kcal', '~750 kkal', '~750 ккал'),
      ),
      (
        Tr('Servings per pack', 'Qadoqda porsiya', 'Порций в упаковке'),
        Tr('20', '20', '20'),
      ),
    ],
    contraindications: [
      Tr(
        'Diabetes or insulin resistance — it is high in carbohydrates; ask a doctor first',
        "Diabet yoki insulinga chidamlilik — uglevodlar ko'p; avval shifokorga murojaat qiling",
        'Диабет или инсулинорезистентность — много углеводов; сначала проконсультируйтесь с врачом',
      ),
      _milk,
      Tr(
        'Overweight or a weight-loss goal',
        "Ortiqcha vazn yoki ozish maqsadi",
        'Избыточный вес или цель похудения',
      ),
      _kidney,
      _special,
    ],
    storage: _dry,
  ),
  'bcaa': ProductInfo(
    benefits: [
      Tr(
        'Amino acids leucine, isoleucine and valine in a 2:1:1 ratio',
        "Leysin, izoleysin va valin aminokislotalari 2:1:1 nisbatda",
        'Аминокислоты лейцин, изолейцин и валин в соотношении 2:1:1',
      ),
      Tr(
        'Handy during long workouts. If your daily protein is already enough, you can skip it',
        "Uzoq mashg'ulotda qulay. Kunlik oqsil yetarli bo'lsa, qabul qilmasa ham bo'ladi",
        'Удобны во время долгих тренировок. Если суточного белка уже достаточно, можно не принимать',
      ),
    ],
    howToUse: [
      Tr(
        'Dissolve 1 serving (about 10 g) in 300–400 ml of water.',
        "1 porsiyani (taxminan 10 g) 300–400 ml suvda eriting.",
        'Растворите 1 порцию (около 10 г) в 300–400 мл воды.',
      ),
      Tr(
        'Drink before or during training. Up to 2 servings a day.',
        "Mashg'ulotdan oldin yoki paytida iching. Kuniga 2 porsiyagacha.",
        'Пейте перед тренировкой или во время неё. Не более 2 порций в день.',
      ),
    ],
    facts: [
      (Tr('Serving', 'Porsiya', 'Порция'), Tr('~10 g', '~10 g', '~10 г')),
      (Tr('Ratio', 'Nisbat', 'Соотношение'), Tr('2:1:1', '2:1:1', '2:1:1')),
      (
        Tr('Servings per pack', 'Qadoqda porsiya', 'Порций в упаковке'),
        Tr('40', '40', '40'),
      ),
    ],
    contraindications: [
      Tr(
        'Individual intolerance',
        "Individual chidamsizlik",
        'Индивидуальная непереносимость',
      ),
      Tr(
        'Chronic kidney or liver disease — only after a doctor’s approval',
        "Surunkali buyrak yoki jigar kasalliklari — faqat shifokor ruxsati bilan",
        'Хронические заболевания почек или печени — только с разрешения врача',
      ),
      _special,
    ],
    storage: _dry,
  ),
  'omega': ProductInfo(
    benefits: [
      Tr(
        'Omega-3 fatty acids are part of a healthy diet and support heart and joint health',
        "Omega-3 yog' kislotalari sog'lom ovqatlanishning bir qismi, yurak va bo'g'imlar salomatligiga yordam beradi",
        'Жирные кислоты омега-3 — часть здорового питания, поддерживают здоровье сердца и суставов',
      ),
      Tr(
        'Useful if you rarely eat fatty fish',
        "Yog'li baliqni kam iste'mol qilsangiz foydali",
        'Полезны, если вы редко едите жирную рыбу',
      ),
    ],
    howToUse: [
      Tr(
        'Take 1–2 capsules a day with a meal that contains some fat.',
        "Kuniga 1–2 kapsula, tarkibida yog' bo'lgan ovqat bilan.",
        'Принимайте 1–2 капсулы в день во время еды, содержащей жиры.',
      ),
      Tr(
        'Swallow whole with water. Do not exceed the dose on the label.',
        "Butunligicha suv bilan yuting. Yorliqdagi dozadan oshirmang.",
        'Проглатывайте целиком, запивая водой. Не превышайте дозу на этикетке.',
      ),
    ],
    facts: [
      (
        Tr('Capsules per pack', 'Qadoqda kapsula', 'Капсул в упаковке'),
        Tr('120', '120', '120'),
      ),
      (
        Tr('Daily dose', 'Kunlik doza', 'Суточная доза'),
        Tr('1–2 capsules', '1–2 kapsula', '1–2 капсулы'),
      ),
    ],
    contraindications: [
      Tr(
        'Allergy to fish or seafood',
        "Baliq yoki dengiz mahsulotlariga allergiya",
        'Аллергия на рыбу или морепродукты',
      ),
      Tr(
        'Blood-clotting disorders or taking blood thinners — ask a doctor first',
        "Qon ivishi buzilishi yoki qon suyultiruvchi dorilar qabul qilish — avval shifokorga murojaat qiling",
        'Нарушения свёртываемости крови или приём разжижающих кровь препаратов — сначала проконсультируйтесь с врачом',
      ),
      Tr(
        'Before planned surgery — ask a doctor',
        "Rejalashtirilgan operatsiyadan oldin — shifokor bilan maslahatlashing",
        'Перед плановой операцией — проконсультируйтесь с врачом',
      ),
      _special,
    ],
    storage: _dry,
  ),
  'multi': ProductInfo(
    benefits: [
      Tr(
        'Helps cover gaps in vitamins and minerals during intense training',
        "Jadal mashg'ulotlarda vitamin va minerallar kamchiligini to'ldirishga yordam beradi",
        'Помогает восполнить недостаток витаминов и минералов при интенсивных тренировках',
      ),
      Tr(
        'Does not replace fruits, vegetables and a varied diet',
        "Meva, sabzavot va xilma-xil ovqatlanishning o'rnini bosmaydi",
        'Не заменяет фрукты, овощи и разнообразное питание',
      ),
    ],
    howToUse: [
      Tr(
        'Take 1 tablet a day with breakfast, with water.',
        "Kuniga 1 tabletka, nonushta bilan, suv bilan.",
        'Принимайте 1 таблетку в день во время завтрака, запивая водой.',
      ),
      Tr(
        'Do not combine with other vitamin complexes without a doctor’s advice — you may exceed safe doses.',
        "Shifokor maslahatisiz boshqa vitamin komplekslari bilan birga qabul qilmang — xavfsiz dozadan oshib ketishi mumkin.",
        'Не сочетайте с другими витаминными комплексами без совета врача — можно превысить безопасные дозы.',
      ),
    ],
    facts: [
      (
        Tr('Tablets per pack', 'Qadoqda tabletka', 'Таблеток в упаковке'),
        Tr('90', '90', '90'),
      ),
      (
        Tr('Daily dose', 'Kunlik doza', 'Суточная доза'),
        Tr('1 tablet', '1 tabletka', '1 таблетка'),
      ),
    ],
    contraindications: [
      Tr(
        'Individual intolerance to any component',
        "Biror tarkibiy qismga individual chidamsizlik",
        'Индивидуальная непереносимость любого компонента',
      ),
      Tr(
        'Taking other vitamin or mineral supplements — risk of overdose',
        "Boshqa vitamin yoki mineral qo'shimchalarini qabul qilish — ortiqcha doza xavfi",
        'Приём других витаминных или минеральных добавок — риск передозировки',
      ),
      Tr(
        'Chronic diseases or regular medication — ask a doctor first',
        "Surunkali kasalliklar yoki doimiy dori qabul qilish — avval shifokorga murojaat qiling",
        'Хронические заболевания или постоянный приём лекарств — сначала проконсультируйтесь с врачом',
      ),
      _special,
    ],
    storage: _dry,
  ),
  'bar': ProductInfo(
    benefits: [
      Tr(
        '20 g of protein in one bar — a handy snack on the go',
        "Bitta batonchikda 20 g oqsil — yo'lda qulay gazak",
        '20 г белка в одном батончике — удобный перекус в дороге',
      ),
      Tr(
        'Good before or after a workout when you have no time to cook',
        "Mashg'ulotdan oldin yoki keyin, ovqat tayyorlashga vaqt bo'lmaganda yaxshi",
        'Подходит до или после тренировки, когда нет времени готовить',
      ),
    ],
    howToUse: [
      Tr(
        'Eat 1 bar as a snack, 1–2 a day at most.',
        "1 ta batonchikni gazak sifatida iste'mol qiling, kuniga ko'pi bilan 1–2 ta.",
        'Съедайте 1 батончик как перекус, не более 1–2 в день.',
      ),
      Tr(
        'It does not replace a full meal.',
        "To'liq ovqatning o'rnini bosmaydi.",
        'Не заменяет полноценный приём пищи.',
      ),
    ],
    facts: [
      (
        Tr('Bar weight', 'Baton vazni', 'Вес батончика'),
        Tr('60 g', '60 g', '60 г'),
      ),
      (
        Tr('Protein per bar', 'Batonda oqsil', 'Белка в батончике'),
        Tr('20 g', '20 g', '20 г'),
      ),
      (
        Tr('Bars per pack', 'Qadoqda baton', 'Батончиков в упаковке'),
        Tr('12', '12', '12'),
      ),
    ],
    contraindications: [
      Tr(
        'Allergy to milk, nuts, soy or gluten — traces are possible, read the label',
        "Sut, yong'oq, soya yoki glyutenga allergiya — iz qoldiqlari bo'lishi mumkin, yorliqni o'qing",
        'Аллергия на молоко, орехи, сою или глютен — возможны следы, читайте этикетку',
      ),
      Tr(
        'Diabetes — check sugar and sweeteners, ask a doctor',
        "Diabet — shakar va shirinlashtiruvchilarni tekshiring, shifokorga murojaat qiling",
        'Диабет — проверьте сахар и подсластители, проконсультируйтесь с врачом',
      ),
      Tr(
        'Sugar alcohols in large amounts can cause bloating',
        "Shakar spirtlari ko'p bo'lsa shishishga olib kelishi mumkin",
        'Сахарные спирты в большом количестве могут вызвать вздутие',
      ),
    ],
    storage: Tr(
      'Store in a dry place up to 25 °C. Do not leave in a hot car.',
      "Quruq joyda 25 °C gacha saqlang. Issiq mashinada qoldirmang.",
      'Хранить в сухом месте при температуре до 25 °C. Не оставлять в жарком автомобиле.',
    ),
  ),
};
