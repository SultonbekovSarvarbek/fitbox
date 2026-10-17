import '../../../core/content/content_l10n.dart';
import '../../nutrition/data/nutrition_goals.dart';
import '../../setup/setup_profile.dart';
import 'market_models.dart';

/// Tavsiya etilgan sportpit mahsuloti va nima uchun.
class SupplementPick {
  const SupplementPick(this.product, this.reason);

  final Product product;
  final Tr reason;
}

/// Anketa (vazn, maqsad, haftalik mashg'ulot) bo'yicha shaxsiy tavsiya.
class NutritionRecommendation {
  const NutritionRecommendation({
    required this.targets,
    required this.supplements,
    required this.plans,
  });

  final DailyTargets targets;
  final List<SupplementPick> supplements;

  /// Obuna uchun mos ratsionlar (eng yaxshisi birinchi).
  final List<MealPlanOffer> plans;
}

NutritionRecommendation recommendFor(SetupProfile u) {
  final targets = dailyTargetsFor(u);
  final has = u.trainingTypes.contains;
  final active = u.trainingDays >= 1;
  final gym = active && (has(TrainingType.strength) || has(TrainingType.hiit));
  final endurance =
      active &&
      (has(TrainingType.running) ||
          has(TrainingType.cardio) ||
          has(TrainingType.hiit));

  Product pick(ProductCategory c) {
    final list = products.where((p) => p.category == c).toList()
      ..sort((a, b) {
        final ga = a.goals.contains(u.goal) ? 0 : 1;
        final gb = b.goals.contains(u.goal) ? 0 : 1;
        return ga != gb ? ga - gb : b.rating.compareTo(a.rating);
      });
    return list.first;
  }

  final picks = <SupplementPick>[];

  // Oqsil: kunlik me'yorning bir qismini ovqatdan olish qiyin bo'lganda.
  if (active || u.goal != Goal.others) {
    picks.add(
      SupplementPick(
        pick(ProductCategory.protein),
        u.goal == Goal.loseWeight
            ? Tr(
                'Your daily protein is ${targets.protein} g. An isolate fills the gap with almost no fat or sugar while you cut.',
                "Kunlik oqsil me'yoringiz ${targets.protein} g. Izolyat quritish paytida yog' va shakarsiz oqsilni to'ldiradi.",
                'Ваша норма белка — ${targets.protein} г. Изолят закрывает дефицит почти без жиров и сахара.',
              )
            : Tr(
                'Your daily protein is ${targets.protein} g. One serving after training makes it much easier to hit.',
                "Kunlik oqsil me'yoringiz ${targets.protein} g. Mashg'ulotdan keyin bir porsiya uni yig'ishni osonlashtiradi.",
                'Ваша норма белка — ${targets.protein} г. Порция после тренировки сильно упрощает её добор.',
              ),
      ),
    );
  }

  if (gym &&
      u.trainingDays >= 2 &&
      {Goal.muscleMass, Goal.shapeBody, Goal.gainWeight}.contains(u.goal)) {
    picks.add(
      SupplementPick(
        pick(ProductCategory.creatine),
        const Tr(
          'You lift or do HIIT several times a week — creatine adds strength and reps.',
          "Haftasiga bir necha marta kuch yoki HIIT qilasiz — kreatin kuch va takrorlarni oshiradi.",
          'Вы занимаетесь силовыми или HIIT несколько раз в неделю — креатин добавляет силу и повторения.',
        ),
      ),
    );
  }

  if (u.goal == Goal.gainWeight || targets.kcal >= 2900) {
    picks.add(
      SupplementPick(
        pick(ProductCategory.gainer),
        Tr(
          'You need about ${targets.kcal} kcal a day — a gainer is an easy way to add calories.',
          "Sizga kuniga taxminan ${targets.kcal} kkal kerak — gainer kaloriyani oson to'ldiradi.",
          'Вам нужно около ${targets.kcal} ккал в день — гейнер помогает добрать калории.',
        ),
      ),
    );
  }

  if ((endurance || u.goal == Goal.loseWeight) && u.trainingDays >= 3) {
    picks.add(
      SupplementPick(
        pick(ProductCategory.aminos),
        const Tr(
          'Frequent cardio or a calorie deficit — amino acids help recovery.',
          "Tez-tez kardio yoki kaloriya tanqisligi — aminokislotalar tiklanishga yordam beradi.",
          'Частое кардио или дефицит калорий — аминокислоты помогают восстановлению.',
        ),
      ),
    );
  }

  if (u.trainingDays >= 4 || u.age >= 35) {
    picks.add(
      SupplementPick(
        pick(ProductCategory.vitamins),
        const Tr(
          'Heavy training or age 35+ raises the need for vitamins and omega-3.',
          "Og'ir mashg'ulot yoki 35+ yosh — vitamin va omega-3 ga ehtiyoj oshadi.",
          'Интенсивные тренировки или возраст 35+ повышают потребность в витаминах и омега-3.',
        ),
      ),
    );
  }

  if (has(TrainingType.teamSports) || has(TrainingType.running)) {
    picks.add(
      SupplementPick(
        pick(ProductCategory.bars),
        const Tr(
          'A bar is a handy protein snack before or after a game or run.',
          "Batonchik o'yin yoki yugurishdan oldin/keyin qulay oqsilli gazak.",
          'Батончик — удобный белковый перекус до или после игры или пробежки.',
        ),
      ),
    );
  }

  return NutritionRecommendation(
    targets: targets,
    supplements: picks,
    plans: recommendPlans(targetKcal: targets.kcal, goal: u.goal),
  );
}
