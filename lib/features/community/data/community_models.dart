import '../../../core/content/content_l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/locale/locale_provider.dart';

class Post {
  const Post({
    required this.id,
    required this.author,
    required this.text,
    required this.likes,
    required this.replies,
    this.liked = false,
  });

  final String id;
  final String author;
  final String text;
  final int likes;
  final int replies;
  final bool liked;

  Post toggleLike() => Post(
    id: id,
    author: author,
    text: text,
    replies: replies,
    liked: !liked,
    likes: likes + (liked ? -1 : 1),
  );
}

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.participants,
    required this.daysLeft,
    this.joined = false,
  });

  final String id;
  final String title;
  final String description;
  final int participants;
  final int daysLeft;
  final bool joined;

  Challenge toggleJoin() => Challenge(
    id: id,
    title: title,
    description: description,
    daysLeft: daysLeft,
    joined: !joined,
    participants: participants + (joined ? -1 : 1),
  );
}

/// 7.4.1 Discussion forum.
/// TODO(backend): serverdan.
final postsProvider = StateNotifierProvider<PostsNotifier, List<Post>>(
  (ref) => PostsNotifier(),
);

class PostsNotifier extends StateNotifier<List<Post>> {
  // TODO(backend): postlar serverdan keladi. Test uchun bo'sh.
  PostsNotifier() : super(const []);

  void add(String author, String text) => state = [
    Post(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      author: author,
      text: text,
      likes: 0,
      replies: 0,
    ),
    ...state,
  ];

  void toggleLike(String id) =>
      state = [for (final p in state) p.id == id ? p.toggleLike() : p];
}

/// 7.4.2 Challenges & competitions.
final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<Challenge>>(
      (ref) => ChallengesNotifier(),
    );

class ChallengesNotifier extends StateNotifier<List<Challenge>> {
  ChallengesNotifier()
    : super(const [
        Challenge(
          id: 'c1',
          title: '10K Steps a Day',
          participants: 0,
          daysLeft: 5,
          description: 'Walk at least 10,000 steps every day for a week.',
        ),
        Challenge(
          id: 'c2',
          title: 'Plank With Hip Twist',
          participants: 0,
          daysLeft: 3,
          description: 'Weekly challenge: 3 sets of 45 seconds daily.',
        ),
        Challenge(
          id: 'c3',
          title: '30 Days of Push Ups',
          participants: 0,
          daysLeft: 21,
          description: 'Start with 10 and add 2 more every day.',
        ),
      ]);

  void toggleJoin(String id) =>
      state = [for (final c in state) c.id == id ? c.toggleJoin() : c];
}

// ---------------------------------------------------------------------------
// O'qilmaganlar (badge)
// ---------------------------------------------------------------------------

/// Foydalanuvchi ko'rgan post / challenge id'lari — telefonda saqlanadi.
/// TODO(backend): server "unread" hisobini qaytaradi, push bilan yangilanadi.
final seenCommunityProvider =
    StateNotifierProvider<SeenCommunityNotifier, Set<String>>(
      (ref) => SeenCommunityNotifier(ref),
    );

class SeenCommunityNotifier extends StateNotifier<Set<String>> {
  SeenCommunityNotifier(this._ref)
    : super(
        (_ref.read(sharedPrefsProvider).getStringList(_key) ?? const [])
            .toSet(),
      );

  static const _key = 'community_seen';
  final Ref _ref;

  /// Hamjamiyat sahifasi ochilganda — hammasi o'qilgan.
  void markAllSeen() {
    final all = {
      for (final p in _ref.read(postsProvider)) p.id,
      for (final c in _ref.read(challengesProvider)) c.id,
    };
    if (all.difference(state).isEmpty) return;
    state = {...state, ...all};
    _ref.read(sharedPrefsProvider).setStringList(_key, state.toList());
  }
}

/// Yangi (ko'rilmagan) post va challenge'lar soni.
final unreadCommunityProvider = Provider<int>((ref) {
  final seen = ref.watch(seenCommunityProvider);
  return [
    for (final p in ref.watch(postsProvider)) p.id,
    for (final c in ref.watch(challengesProvider)) c.id,
  ].where((id) => !seen.contains(id)).length;
});

extension PostL10n on Post {
  /// Demo postlar tarjima qilinadi, foydalanuvchi yozganlari — o'zgarmaydi.
  String textOf(BuildContext context) => postTexts[id]?.of(context) ?? text;
}

extension ChallengeL10n on Challenge {
  String titleOf(BuildContext context) =>
      challengeTitles[id]?.of(context) ?? title;
  String descriptionOf(BuildContext context) =>
      challengeDescriptions[id]?.of(context) ?? description;
}
