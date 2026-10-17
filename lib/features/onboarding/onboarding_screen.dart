import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/assets/app_images.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/language_button.dart';
import '../../core/widgets/media_placeholder.dart';
import '../../core/widgets/primary_button.dart';

/// 2. On boarding — design/1.png (chap telefon):
/// 3 ta vertikal rasm kollaji, katta UPPERCASE sarlavha, Sign in / Sign up.
///
/// Animatsiya tartibi: panellar (o'rtadagisi tepadan, yonlari pastdan) →
/// sarlavha → lime belgi chapdan o'ngga yoyiladi → matn → tugmalar.
/// Rasm fonda doim sekin "nafas oladi" (Ken Burns).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  /// Matn kollaj ajralishining oxiriga yaqin chiqa boshlaydi.
  static const _textDelay = Duration(milliseconds: 2000);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: LanguageButton(),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Expanded(child: _Collage()),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: _textDelay,
                child: _Headline(
                  text: l10n.welcomeHeadline,
                  highlight: l10n.welcomeHighlight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FadeSlideIn(
                delay: _textDelay,
                index: 4,
                child: Text(
                  l10n.welcomeSubtitle,
                  style: AppTextStyles.bodySecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: _textDelay,
                index: 7,
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: l10n.signIn.toUpperCase(),
                        onPressed: () => context.go(Routes.login),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        label: l10n.signUp.toUpperCase(),
                        variant: ButtonVariant.outline,
                        onPressed: () {
                          context.go(Routes.login);
                          context.push(Routes.signup);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// design/1.png: bitta rasm 3 ta vertikal panelga bo'linadi —
/// o'rtadagisi baland, yon tomondagilari pastroq. Har panel rasmning o'z qismini ko'rsatadi.
///
/// Kinematografik intro (bitta `_intro` controller):
///   0.00–0.25  qoradan yorishadi (fade-in)
///   0.00–0.60  rasm yaxlit, kadrni to'liq qoplaydi, 1.25× dan 1.0× gacha uzoqlashadi
///   0.50–1.00  yaxlit rasm 3 panelga ajraladi: oraliq ochiladi, burchak yumaloqlanadi,
///              yon panellar qisqaradi
/// Keyin fonda doimiy sekin "nafas" (Ken Burns, `_breath`).
class _Collage extends StatefulWidget {
  const _Collage();

  /// Intro davomiyligi — sarlavha shundan keyin chiqadi.
  static const introDuration = Duration(milliseconds: 2600);

  @override
  State<_Collage> createState() => _CollageState();
}

class _CollageState extends State<_Collage> with TickerProviderStateMixin {
  static const _gap = AppSpacing.sm;
  static const _sideHeight = 0.78;

  late final _intro = AnimationController(
    vsync: this,
    duration: _Collage.introDuration,
  )..forward();

  late final _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  late final _fade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, 0.25, curve: Curves.easeOut),
  );
  late final _dolly = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
  );
  late final _split = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.5, 1, curve: Curves.easeInOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _intro.addStatusListener((s) {
      if (s == AnimationStatus.completed) _breath.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppImages.onboardingMain,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const MediaPlaceholder(radius: 0),
    );

    return LayoutBuilder(
      builder: (_, c) => AnimatedBuilder(
        animation: Listenable.merge([_intro, _breath]),
        builder: (_, _) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          final split = _split.value;

          // Ajralish: 0 — yaxlit rasm, 1 — 3 ta panel.
          final gap = _gap * split;
          final radius = AppRadius.lg * split;
          final sideH = h * (1 - (1 - _sideHeight) * split);
          final sideTop = (h - sideH) / 2;
          final side = (w - 2 * gap) / 4;
          final panels = [
            Rect.fromLTWH(0, sideTop, side, sideH),
            Rect.fromLTWH(side + gap, 0, side * 2, h),
            Rect.fromLTWH(side * 3 + gap * 2, sideTop, side, sideH),
          ];

          // Kamera: 1.25× → 1.0× (dolly-out), keyin 1.0 ↔ 1.06 nafas.
          final scale =
              1.25 -
              0.25 * _dolly.value +
              0.06 * Curves.easeInOut.transform(_breath.value);

          return Opacity(
            opacity: _fade.value,
            child: Stack(
              children: [
                for (final r in panels)
                  Positioned.fromRect(
                    rect: r,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          // Panel ichida rasm o'z joyida turadi —
                          // ajralish paytida ham sahna yaxlit ko'rinadi.
                          Positioned(
                            left: -r.left,
                            top: -r.top,
                            width: w,
                            height: h,
                            child: Transform.scale(scale: scale, child: image),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// "KELING, SIZ BILAN YAQINROQ [TANISHAMIZ]" — oxirgi so'z ostida
/// lime fon chapdan o'ngga yoyiladi.
class _Headline extends StatelessWidget {
  const _Headline({required this.text, required this.highlight});

  final String text;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.display;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: '${text.toUpperCase()} '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _HighlightSweep(text: highlight.toUpperCase(), style: style),
          ),
        ],
      ),
    );
  }
}

class _HighlightSweep extends StatelessWidget {
  const _HighlightSweep({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      // Sarlavha (~2.0 s) chiqqandan keyin: ~2.3 s dan 3.4 s gacha.
      duration: const Duration(milliseconds: 3400),
      curve: const Interval(0.68, 1, curve: Curves.easeOutCubic),
      builder: (_, v, _) => Stack(
        children: [
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: v,
              child: const ColoredBox(color: AppColors.primary),
            ),
          ),
          // Fon yoyilguncha matn oq, keyin qora — doim o'qiladi.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              text,
              style: style.copyWith(
                color: Color.lerp(
                  AppColors.textPrimary,
                  AppColors.textOnPrimary,
                  v,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
