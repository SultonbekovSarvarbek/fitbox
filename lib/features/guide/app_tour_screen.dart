import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/primary_button.dart';
import 'data/guide_content.dart';

const _tourSeenKey = 'tour_seen';

bool tourSeen(WidgetRef ref) =>
    ref.read(sharedPrefsProvider).getBool(_tourSeenKey) ?? false;

/// Kirgandan keyin: ilova maqsadi va nimalar qila olishi — qisqa sahifalar.
/// Bir marta ko'rsatiladi; keyin Profil → Qo'llanma'dan qayta ochiladi.
class AppTourScreen extends ConsumerStatefulWidget {
  const AppTourScreen({super.key});

  @override
  ConsumerState<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends ConsumerState<AppTourScreen> {
  final _pages = PageController();
  var _index = 0;

  static const _topics = [appMission, ...guideTopics];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _finish() {
    ref.read(sharedPrefsProvider).setBool(_tourSeenKey, true);
    context.go(Routes.home);
  }

  void _next() {
    HapticFeedback.selectionClick();
    if (_index == _topics.length - 1) {
      _finish();
    } else {
      _pages.nextPage(duration: AppMotion.medium, curve: AppMotion.curve);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final last = _index == _topics.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  Text(
                    '${_index + 1} / ${_topics.length}',
                    style: AppTextStyles.captionSecondary,
                  ),
                  const Spacer(),
                  if (!last)
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        l10n.skip,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _topics.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _TourPage(
                  topic: _topics[i],
                  isMission: i == 0,
                  active: i == _index,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _topics.length; i++)
                  AnimatedContainer(
                    duration: AppMotion.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? AppColors.primary
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: last ? l10n.letsStart : l10n.next,
                icon: last ? Icons.bolt_rounded : Icons.arrow_forward_rounded,
                expanded: true,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourPage extends StatelessWidget {
  const _TourPage({
    required this.topic,
    required this.isMission,
    required this.active,
  });

  final GuideTopic topic;
  final bool isMission;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Har sahifaga kirganda ikonka "sakrab" chiqadi.
          TweenAnimationBuilder<double>(
            key: ValueKey(active),
            tween: Tween(begin: active ? 0.6 : 1, end: 1),
            duration: AppMotion.slow,
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(
              scale: v,
              alignment: Alignment.centerLeft,
              child: child,
            ),
            child: Container(
              width: isMission ? 112 : 88,
              height: isMission ? 112 : 88,
              decoration: BoxDecoration(
                color: isMission
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                topic.icon,
                size: isMission ? 64 : 48,
                color: isMission ? AppColors.textOnPrimary : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (isMission) ...[
            Text(
              context.l10n.whyFitBody.toUpperCase(),
              style: AppTextStyles.overline.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            topic.title.of(context),
            style: isMission ? AppTextStyles.display : AppTextStyles.h1,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(topic.summary.of(context), style: AppTextStyles.body),
          if (topic.steps.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            for (final (i, step) in topic.steps.take(3).indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: Text('${i + 1}', style: AppTextStyles.caption),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        step.of(context),
                        style: AppTextStyles.bodySecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
