import '../auth/session.dart';
import 'package:flutter/material.dart';
import '../progress/data/progress_models.dart';
import '../profile/widgets/user_avatar.dart';
import '../../core/assets/app_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'setup_profile.dart';
import '../../core/content/content_l10n.dart';
import 'widgets/wheel_picker.dart';

/// 4. Set Up — 4.1 … 4.7 qadamlari bitta wizard ichida.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  late final _profile = ref.read(userProvider).copy();
  final _controller = PageController();
  late final _name = TextEditingController(text: _profile.fullName);
  late final _nickname = TextEditingController(text: _profile.nickname);
  late final _phone = TextEditingController(text: _profile.phone);
  int _step = 0; // 0 = intro, 1..7 = 4.1..4.7

  static const _stepCount = 8;

  @override
  void dispose() {
    _controller.dispose();
    _name.dispose();
    _nickname.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _go(int step) {
    setState(() => _step = step);
    _controller.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    if (_step == _stepCount - 1) {
      // TODO(backend): profilni serverga saqlash.
      ref.read(userProvider.notifier).state = _profile.copy()
        ..activity = switch (_profile.trainingDays) {
          <= 2 => ActivityLevel.beginner,
          <= 4 => ActivityLevel.intermediate,
          _ => ActivityLevel.advanced,
        }
        // Avatar Set Up davomida alohida saqlangan — eskisi bilan almashtirmaymiz.
        ..avatarPath = ref.read(userProvider).avatarPath
        ..fullName = _name.text
        ..nickname = _nickname.text
        ..phone = _phone.text;
      ref.read(weightLogProvider.notifier).add(_profile.weightKg.toDouble());
      Session.signIn(ref.read(sharedPrefsProvider));
      // Birinchi kirish — ilova maqsadi va imkoniyatlari bilan tanishtiruv.
      context.go(Routes.recommendation);
    } else {
      _go(_step + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = _profile;

    final pages = <Widget>[
      const _Intro(),
      _Step(
        title: l10n.genderTitle,
        child: Column(
          children: [
            for (final g in Gender.values) ...[
              _GenderCard(
                icon: g == Gender.male
                    ? Icons.male_rounded
                    : Icons.female_rounded,
                asset: AppImages.gender(g.name),
                label: g == Gender.male ? l10n.male : l10n.female,
                selected: p.gender == g,
                onTap: () => setState(() => p.gender = g),
              ),
              if (g == Gender.male) const SizedBox(height: AppSpacing.xl),
            ],
          ],
        ),
      ),
      _Step(
        title: l10n.ageTitle,
        child: WheelPicker(
          min: 12,
          max: 90,
          value: p.age,
          onChanged: (v) => setState(() => p.age = v),
        ),
      ),
      _Step(
        title: l10n.weightTitle,
        child: WheelPicker(
          min: 30,
          max: 200,
          value: p.weightKg,
          unit: l10n.kg,
          onChanged: (v) => setState(() => p.weightKg = v),
        ),
      ),
      _Step(
        title: l10n.heightTitle,
        child: WheelPicker(
          min: 120,
          max: 230,
          value: p.heightCm,
          unit: l10n.cm,
          onChanged: (v) => setState(() => p.heightCm = v),
        ),
      ),
      _Step(
        title: l10n.goalTitle,
        child: _OptionList<Goal>(
          values: Goal.values,
          selected: p.goal,
          icon: (g) => switch (g) {
            Goal.loseWeight => Icons.trending_down_rounded,
            Goal.gainWeight => Icons.trending_up_rounded,
            Goal.muscleMass => Icons.fitness_center_rounded,
            Goal.shapeBody => Icons.accessibility_new_rounded,
            Goal.others => Icons.more_horiz_rounded,
          },
          label: (g) => switch (g) {
            Goal.loseWeight => l10n.goalLoseWeight,
            Goal.gainWeight => l10n.goalGainWeight,
            Goal.muscleMass => l10n.goalMuscleMass,
            Goal.shapeBody => l10n.goalShapeBody,
            Goal.others => l10n.goalOthers,
          },
          onSelect: (g) => setState(() => p.goal = g),
        ),
      ),
      _Step(
        title: _trainingTitle.of(context),
        child: _TrainingStep(
          days: p.trainingDays,
          types: p.trainingTypes,
          onDays: (d) => setState(() => p.trainingDays = d),
          onToggle: (t) => setState(() {
            p.trainingTypes = {...p.trainingTypes};
            p.trainingTypes.contains(t)
                ? p.trainingTypes.remove(t)
                : p.trainingTypes.add(t);
          }),
        ),
      ),
      _Step(
        title: l10n.profileTitle,
        child: Column(
          children: [
            const UserAvatar(radius: 48, editable: true),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: l10n.fullName,
              controller: _name,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.nickname,
              controller: _nickname,
              prefixIcon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.mobileNumber,
              controller: _phone,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    ];

    final isIntro = _step == 0;
    return Scaffold(
      backgroundColor: isIntro ? AppColors.primary : AppColors.background,
      appBar: isIntro
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => _go(_step - 1),
              ),
              title: _Progress(step: _step, total: _stepCount - 1),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: Center(
                    child: Text(
                      '$_step/${_stepCount - 1}',
                      style: AppTextStyles.captionSecondary,
                    ),
                  ),
                ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: isIntro
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(0, 54),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          l10n.getStarted,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  : PrimaryButton(
                      label: _step == _stepCount - 1
                          ? l10n.start
                          : l10n.continueBtn,
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

/// design/2.png'dagi "Get ready" — butun ekran lime.
class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dark = AppColors.textOnPrimary;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: dark, shape: BoxShape.circle),
            child: const Icon(
              Icons.bolt_rounded,
              size: 72,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.getReady,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(color: dark),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.setupTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(color: dark),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.setupSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: dark.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.display.copyWith(fontSize: 28),
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: step / total),
        duration: const Duration(milliseconds: 300),
        builder: (_, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: 6,
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceLight,
        ),
      ),
    );
  }
}

/// Jins tanlash: katta doira (tanlangani lime), ostida nomi. Bittasi tepada, bittasi pastda.
/// Rasm: `assets/images/gender_male.png`, `gender_female.png` — bo'lmasa ikon chiqadi.
class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.icon,
    required this.asset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String asset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _size = 150.0;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.textOnPrimary : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 32,
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(icon, size: 84, color: fg),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: AppTextStyles.h3.copyWith(
              color: selected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionList<T> extends StatelessWidget {
  const _OptionList({
    required this.values,
    required this.selected,
    required this.label,
    required this.icon,
    required this.onSelect,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final IconData Function(T) icon;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final v in values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Material(
              color: v == selected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onSelect(v),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: v == selected
                              ? AppColors.textOnPrimary
                              : AppColors.surfaceLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon(v),
                          size: 20,
                          color: v == selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          label(v),
                          style: AppTextStyles.title.copyWith(
                            color: v == selected
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (v == selected)
                        const Icon(
                          Icons.check_rounded,
                          color: AppColors.textOnPrimary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

const _trainingTitle = Tr(
  'What does your training week look like?',
  "Haftangiz mashg'ulotlarda qanday o'tadi?",
  'Как выглядит ваша тренировочная неделя?',
);

const trainingTypeNames = <TrainingType, Tr>{
  TrainingType.strength: Tr('Strength / gym', "Kuch / zal", 'Силовые / зал'),
  TrainingType.cardio: Tr('Cardio', 'Kardio', 'Кардио'),
  TrainingType.running: Tr('Running', 'Yugurish', 'Бег'),
  TrainingType.hiit: Tr(
    'HIIT / CrossFit',
    'HIIT / CrossFit',
    'HIIT / кроссфит',
  ),
  TrainingType.yoga: Tr(
    'Yoga / stretching',
    'Yoga / cho\'zilish',
    'Йога / растяжка',
  ),
  TrainingType.teamSports: Tr(
    'Team sports',
    'Jamoaviy sport',
    'Командные виды',
  ),
};

/// Haftasiga necha kun + qanday mashg'ulot turlari (bir nechtasini tanlash mumkin).
class _TrainingStep extends StatelessWidget {
  const _TrainingStep({
    required this.days,
    required this.types,
    required this.onDays,
    required this.onToggle,
  });

  final int days;
  final Set<TrainingType> types;
  final ValueChanged<int> onDays;
  final ValueChanged<TrainingType> onToggle;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, bool on, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: on ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.title.copyWith(
            color: on ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          const Tr(
            'Days per week',
            'Haftasiga necha kun',
            'Дней в неделю',
          ).of(context),
          style: AppTextStyles.captionSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var d = 0; d <= 7; d++) chip('$d', d == days, () => onDays(d)),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          const Tr(
            'What do you do? (pick all that apply)',
            'Nima bilan shug\'ullanasiz? (bir nechtasini tanlang)',
            'Чем занимаетесь? (можно несколько)',
          ).of(context),
          style: AppTextStyles.captionSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final t in TrainingType.values)
              chip(
                trainingTypeNames[t]!.of(context),
                types.contains(t),
                () => onToggle(t),
              ),
          ],
        ),
      ],
    );
  }
}
