import '../../../core/content/content_l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ResourceKind { article, video }

class Resource {
  const Resource({
    required this.id,
    required this.kind,
    required this.title,
    required this.minutes,
    required this.category,
    this.body = const [],
  });

  final String id;
  final ResourceKind kind;
  final String title;

  /// Maqola uchun — o'qish vaqti, video uchun — davomiyligi.
  final int minutes;
  final String category;
  final List<String> body;
}

/// 11.2.1 Articles & Tips · 11.2.2 Workout Videos.
/// TODO(backend/cms): kontent serverdan, tanlangan tilda keladi.
const demoResources = [
  Resource(
    id: 'a1',
    kind: ResourceKind.article,
    minutes: 5,
    category: 'Nutrition',
    title: 'Supplement Guide: what you really need',
    body: [
      'Most people can cover their needs with whole foods. Supplements are there to fill gaps, not to replace meals.',
      'Protein powder is convenient if you struggle to reach your daily protein target. Creatine monohydrate is the most researched supplement for strength.',
      'Vitamin D is worth checking with your doctor, especially in winter. Everything else — ask whether it solves a real problem for you.',
    ],
  ),
  Resource(
    id: 'a2',
    kind: ResourceKind.article,
    minutes: 8,
    category: 'Training',
    title: '15 Quick & Effective Daily Routines',
    body: [
      'You do not need an hour in the gym every day. Short, focused sessions done consistently beat long sessions done rarely.',
      'Try 10 minutes of mobility in the morning, a 15-minute bodyweight circuit at lunch, and a short walk after dinner.',
    ],
  ),
  Resource(
    id: 'a3',
    kind: ResourceKind.article,
    minutes: 4,
    category: 'Recovery',
    title: 'Why sleep is your best recovery tool',
    body: [
      'Muscles grow while you rest. Aim for 7–9 hours of sleep and keep a consistent schedule, even on weekends.',
    ],
  ),
  Resource(
    id: 'v1',
    kind: ResourceKind.video,
    minutes: 12,
    category: 'Strength',
    title: 'Perfect Push Up Technique',
  ),
  Resource(
    id: 'v2',
    kind: ResourceKind.video,
    minutes: 20,
    category: 'Mobility',
    title: 'Full Body Morning Stretch',
  ),
  Resource(
    id: 'v3',
    kind: ResourceKind.video,
    minutes: 18,
    category: 'HIIT',
    title: 'Home HIIT — No Equipment',
  ),
  Resource(
    id: 'v4',
    kind: ResourceKind.video,
    minutes: 15,
    category: 'Core',
    title: 'Core Burnout in 15 Minutes',
  ),
];

Resource? resourceById(String id) {
  for (final r in demoResources) {
    if (r.id == id) return r;
  }
  return null;
}

/// 11.3 Favorite — sevimli maqola/videolar id'lari.
/// TODO(storage): lokal xotira/serverga saqlash.
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(const {'a1', 'v2'});

  void toggle(String id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

extension ResourceL10n on Resource {
  String titleOf(BuildContext context) =>
      resourceTitles[id]?.of(context) ?? title;
  String categoryOf(BuildContext context) =>
      trKey(context, resourceCategories, category);
  List<String> bodyOf(BuildContext context) =>
      resourceBodies[id]?.map((t) => t.of(context)).toList() ?? body;
}
