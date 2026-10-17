import '../../../core/content/content_l10n.dart' as content;
import 'package:flutter/widgets.dart';

enum MealType { breakfast, lunch, dinner }

class Meal {
  const Meal({
    required this.id,
    required this.title,
    required this.type,
    required this.kcal,
    required this.minutes,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
  });

  final String id;
  final String title;
  final MealType type;
  final int kcal;
  final int minutes;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
}

/// 7.3.2 Meal Ideas.
/// TODO(backend/ai): serverdan va AI meal_planner'dan olinadi.
const demoMeals = [
  Meal(
    id: 'm1',
    title: 'Oatmeal With Berries',
    type: MealType.breakfast,
    kcal: 320,
    minutes: 10,
    protein: 12,
    carbs: 54,
    fat: 7,
    ingredients: [
      'Oats 60 g',
      'Milk 200 ml',
      'Blueberries 50 g',
      'Honey 1 tsp',
    ],
  ),
  Meal(
    id: 'm2',
    title: 'Egg & Avocado Toast',
    type: MealType.breakfast,
    kcal: 380,
    minutes: 12,
    protein: 18,
    carbs: 30,
    fat: 20,
    ingredients: [
      'Whole grain bread 2 slices',
      'Eggs 2',
      'Avocado ½',
      'Salt, pepper',
    ],
  ),
  Meal(
    id: 'm3',
    title: 'Greek Yogurt Bowl',
    type: MealType.breakfast,
    kcal: 280,
    minutes: 5,
    protein: 20,
    carbs: 32,
    fat: 6,
    ingredients: ['Greek yogurt 200 g', 'Granola 30 g', 'Banana ½'],
  ),
  Meal(
    id: 'm4',
    title: 'Chicken Rice Bowl',
    type: MealType.lunch,
    kcal: 540,
    minutes: 25,
    protein: 42,
    carbs: 60,
    fat: 12,
    ingredients: [
      'Chicken breast 150 g',
      'Rice 80 g',
      'Broccoli 100 g',
      'Soy sauce',
    ],
  ),
  Meal(
    id: 'm5',
    title: 'Tuna Salad',
    type: MealType.lunch,
    kcal: 410,
    minutes: 10,
    protein: 35,
    carbs: 18,
    fat: 22,
    ingredients: [
      'Tuna 120 g',
      'Lettuce',
      'Cherry tomatoes',
      'Olive oil 1 tbsp',
    ],
  ),
  Meal(
    id: 'm6',
    title: 'Salmon & Vegetables',
    type: MealType.dinner,
    kcal: 480,
    minutes: 30,
    protein: 36,
    carbs: 20,
    fat: 26,
    ingredients: ['Salmon 150 g', 'Zucchini', 'Bell pepper', 'Lemon'],
  ),
  Meal(
    id: 'm7',
    title: 'Turkey Stir Fry',
    type: MealType.dinner,
    kcal: 430,
    minutes: 20,
    protein: 38,
    carbs: 35,
    fat: 12,
    ingredients: [
      'Turkey 150 g',
      'Mixed vegetables 200 g',
      'Garlic',
      'Soy sauce',
    ],
  ),
];

Meal? mealById(String id) {
  for (final m in demoMeals) {
    if (m.id == id) return m;
  }
  return null;
}

extension MealL10n on Meal {
  String titleOf(BuildContext context) =>
      content.mealTitles[id]?.of(context) ?? title;
  List<String> ingredientsOf(BuildContext context) => [
    for (final i in ingredients) content.trKey(context, content.ingredients, i),
  ];
}
