import '../setup/setup_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/pill_tabs.dart';
import '../../core/widgets/primary_button.dart';
import 'data/community_models.dart';

/// 7.4 Community: 7.4.1 Discussion forum · 7.4.2 Challenges & competitions.
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(seenCommunityProvider.notifier).markAllSeen(),
    );
  }

  Future<void> _writePost() async {
    final you = context.l10n.you;
    final controller = TextEditingController();
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 4,
              style: AppTextStyles.body,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(hintText: ctx.l10n.writePostHint),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: ctx.l10n.publish,
              expanded: true,
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (text != null && text.isNotEmpty) {
      final name = ref.read(userProvider).displayName;
      ref.read(postsProvider.notifier).add(name.isEmpty ? you : name, text);
      ref.read(seenCommunityProvider.notifier).markAllSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(l10n.community, style: AppTextStyles.h2),
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              onPressed: _writePost,
              child: const Icon(Icons.edit_rounded),
            )
          : null,
      body: Column(
        children: [
          PillTabs(
            labels: [l10n.discussionForum, l10n.challengesCompetitions],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _tab == 0 ? const _ForumTab() : const _ChallengesTab(),
          ),
        ],
      ),
    );
  }
}

class _ForumTab extends ConsumerWidget {
  const _ForumTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final posts = ref.watch(postsProvider);
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            l10n.noPostsYet,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 88),
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) {
        final p = posts[i];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      p.author[0],
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(p.author, style: AppTextStyles.title),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(p.textOf(context), style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  InkWell(
                    onTap: () =>
                        ref.read(postsProvider.notifier).toggleLike(p.id),
                    child: Row(
                      children: [
                        Icon(
                          p.liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text('${p.likes}', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.repliesCount(p.replies),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChallengesTab extends ConsumerWidget {
  const _ChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final challenges = ref.watch(challengesProvider);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: challenges.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) {
        final c = challenges[i];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(c.titleOf(context), style: AppTextStyles.h3),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                c.descriptionOf(context),
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.participantsCount(c.participants)} · ${l10n.daysLeft(c.daysLeft)}',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  PrimaryButton(
                    label: c.joined ? l10n.joined : l10n.join,
                    variant: c.joined
                        ? ButtonVariant.secondary
                        : ButtonVariant.primary,
                    compact: true,
                    onPressed: () =>
                        ref.read(challengesProvider.notifier).toggleJoin(c.id),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
