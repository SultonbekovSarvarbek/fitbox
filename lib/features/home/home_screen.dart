import '../motivation/data/motivation_providers.dart';
import '../motivation/widgets/mission_card.dart';
import '../devices/data/health_sync.dart';
import 'package:flutter/material.dart';
import '../notifications/notifications_screen.dart';
import '../community/data/community_models.dart';
import '../progress/data/progress_models.dart';
import '../../core/widgets/animations.dart';
import '../profile/widgets/user_avatar.dart';
import '../../core/assets/app_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/language_button.dart';
import '../../core/widgets/media_placeholder.dart';
import '../../core/widgets/section_title.dart';
import '../resources/data/resources_models.dart';
import '../setup/setup_profile.dart';
import '../workout/data/workout_models.dart';

part 'home_screen_widgets.dart';

/// 5. Home Page — design/1.png (o'rtadagi telefon) + design/2.png (Steps kartasi).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final routines = ref
        .watch(routinesProvider)
        .where((r) => !r.isCustom)
        .toList();
    // TODO(ai): kun bo'yicha shaxsiy reja (plan_generator).
    final hero = ref.watch(autoRoutineProvider(DateTime.now().weekday));
    final program = routines.where((r) => r != hero).take(4).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.lg + AppSpacing.navOverlap,
          ),
          children: [
            // Sarlavha
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.readyUser(
                            ref.watch(userProvider).displayName.isEmpty
                                ? l10n.friend
                                : ref.watch(userProvider).displayName,
                          ),
                          style: AppTextStyles.h2,
                        ),
                      ],
                    ),
                  ),
                  const LanguageButton(),
                  IconButton(
                    onPressed: () => context.push(Routes.search),
                    tooltip: l10n.search,
                    icon: const Icon(Icons.search_rounded),
                  ),
                  IconButton(
                    onPressed: () => context.push(Routes.notifications),
                    icon: CountBadge(
                      count: ref.watch(unreadNotificationsProvider),
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                  ),
                  UserAvatar(
                    radius: 22,
                    onTap: () => context.push(Routes.profile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Bugungi vazifa — mashg'ulotga undaydi (seriya, qolgan vaqt, daraja).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: MissionCard(routine: hero),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Barcha bo'limlar bir joyda — nima qayerdaligi ko'rinib tursin.
            SectionTitle(title: l10n.sectionsTitle),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _SectionsGrid(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Soat ulangan bo'lsa — qadam, puls, uyqu.
            if (ref.watch(healthSyncProvider).connected) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _WatchStrip(data: ref.watch(healthSyncProvider)),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Katta karta: bugungi mashg'ulot + kunlik dastur (chapga suriladi).
            SectionTitle(
              title: l10n.workoutsTitle,
              onSeeAll: () => context.go(Routes.workout),
            ),
            _HeroCarousel(routines: [hero, ...program]),
            const SizedBox(height: AppSpacing.lg),

            // Bu hafta.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _WeekCard(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 10. Articles & Tips
            SectionTitle(
              title: l10n.articlesTips,
              onSeeAll: () => context.go(Routes.resources),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  for (final a
                      in demoResources
                          .where((r) => r.kind == ResourceKind.article)
                          .take(2))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        onTap: () => context.push(Routes.resource(a.id)),
                        child: Row(
                          children: [
                            MediaPlaceholder(
                              asset: AppImages.resource(a.id),
                              icon: Icons.article_rounded,
                              width: 72,
                              height: 72,
                              radius: AppRadius.md,
                              iconSize: 28,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.titleOf(context),
                                    style: AppTextStyles.title,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.minRead(a.minutes),
                                    style: AppTextStyles.captionSecondary,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
