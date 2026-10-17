import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../setup/setup_profile.dart';
import 'data/market_models.dart';
import 'data/subscription_models.dart';

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

String formatDate(BuildContext context, DateTime d) =>
    DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(d);

/// Obunani rasmiylashtirish: muddat (1 / 3 oy), kunlik mahallar, boshlanish sanasi, manzil.
/// Keyingi qadam — to'lov ekrani (`SubscriptionPaymentScreen`).
class SubscribeScreen extends ConsumerStatefulWidget {
  const SubscribeScreen({super.key, required this.planId});

  final String planId;

  @override
  ConsumerState<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends ConsumerState<SubscribeScreen> {
  final _form = GlobalKey<FormState>();
  final _address = TextEditingController();
  late final _phone = TextEditingController(text: ref.read(userProvider).phone);
  var _months = 1;
  var _slots = {...MealSlot.values};
  late var _start = DateUtils.dateOnly(
    DateTime.now(),
  ).add(const Duration(days: 1));

  late final _plan = mealPlanById(widget.planId)!;

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_form.currentState!.validate()) return;
    context.push(
      Routes.subscriptionPayment,
      extra: SubscriptionDraft(
        planId: _plan.id,
        months: _months,
        slots: _slots,
        startDate: _start,
        address: _address.text.trim(),
        phone: _phone.text.trim(),
      ),
    );
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: today.add(const Duration(days: 1)),
      lastDate: today.add(const Duration(days: 60)),
    );
    if (d != null) setState(() => _start = d);
  }

  @override
  Widget build(BuildContext context) {
    final price = subscriptionPrice(
      _plan,
      months: _months,
      slots: _slots.length,
    );
    final tomorrow = DateUtils.dateOnly(
      DateTime.now(),
    ).add(const Duration(days: 1));

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(text, style: AppTextStyles.h3),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, 'Subscription', 'Obuna', 'Подписка')),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kitchenName, style: AppTextStyles.captionSecondary),
                  const SizedBox(height: 2),
                  Text(_plan.title.of(context), style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    '${context.l10n.kcal(_plan.kcal)} · '
                    '${_t(context, 'fresh meals delivered by courier', 'kuryer yangi taom yetkazadi', 'курьер привозит свежие блюда')}',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final m in _plan.menu)
                    Text('• ${m.of(context)}', style: AppTextStyles.body),
                ],
              ),
            ),
            label(_t(context, 'Duration', 'Muddat', 'Срок')),
            Row(
              children: [
                for (final m in const [1, 3])
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: m == 1 ? AppSpacing.sm : 0,
                      ),
                      child: _Choice(
                        selected: _months == m,
                        onTap: () => setState(() => _months = m),
                        title: m == 1
                            ? _t(context, '1 month', '1 oy', '1 месяц')
                            : _t(context, '3 months', '3 oy', '3 месяца'),
                        subtitle: formatSum(
                          context,
                          subscriptionPrice(
                            _plan,
                            months: m,
                            slots: _slots.length,
                          ).total,
                        ),
                        badge: m == 3
                            ? '−${(threeMonthDiscount * 100).round()}%'
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            label(
              _t(
                context,
                'Courier brings food',
                'Kuryer olib keladi',
                'Курьер привозит',
              ),
            ),
            for (final s in MealSlot.values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _Choice(
                  selected: _slots.contains(s),
                  onTap: () => setState(() {
                    // Kamida bitta mahal qolishi kerak.
                    if (_slots.contains(s)) {
                      if (_slots.length > 1) _slots = {..._slots}..remove(s);
                    } else {
                      _slots = {..._slots, s};
                    }
                  }),
                  icon: s.icon,
                  title: s.label.of(context),
                  subtitle: s.window,
                ),
              ),
            label(
              _t(context, 'Start date', 'Boshlanish sanasi', 'Дата начала'),
            ),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _DateChip(
                  text: _t(context, 'Tomorrow', 'Ertaga', 'Завтра'),
                  selected: _start == tomorrow,
                  onTap: () => setState(() => _start = tomorrow),
                ),
                _DateChip(
                  text: _start == tomorrow
                      ? _t(
                          context,
                          'Pick a date',
                          'Sana tanlash',
                          'Выбрать дату',
                        )
                      : formatDate(context, _start),
                  icon: Icons.calendar_month_rounded,
                  selected: _start != tomorrow,
                  onTap: _pickDate,
                ),
              ],
            ),
            label(_t(context, 'Delivery', 'Yetkazish', 'Доставка')),
            AppTextField(
              label: context.l10n.deliveryAddress,
              controller: _address,
              prefixIcon: Icons.location_on_outlined,
              validator: (v) => (v == null || v.trim().length < 5)
                  ? context.l10n.fieldRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: context.l10n.mobileNumber,
              controller: _phone,
              hint: '+998 __ ___ __ __',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.replaceAll(RegExp(r'\D'), '').length < 9)
                  ? context.l10n.fieldRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              color: AppColors.surfaceLight,
              child: Column(
                children: [
                  _Line(
                    '${formatSum(context, price.perDay)} × ${price.days} ${_t(context, 'days', 'kun', 'дн.')}',
                    formatSum(context, price.subtotal),
                  ),
                  if (price.discount > 0)
                    _Line(
                      _t(
                        context,
                        '3-month discount',
                        '3 oylik chegirma',
                        'Скидка за 3 месяца',
                      ),
                      '−${formatSum(context, price.discount)}',
                    ),
                  const Divider(height: AppSpacing.lg),
                  _Line(
                    context.l10n.total,
                    formatSum(context, price.total),
                    big: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: _t(
                context,
                'Continue to payment',
                "To'lovga o'tish",
                'Перейти к оплате',
              ),
              icon: Icons.lock_outline_rounded,
              expanded: true,
              onPressed: _continue,
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.left, this.right, {this.big = false});

  final String left;
  final String right;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final style = big
        ? AppTextStyles.h2.copyWith(color: AppColors.primary)
        : AppTextStyles.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              left,
              style: big ? AppTextStyles.title : AppTextStyles.bodySecondary,
            ),
          ),
          Text(right, style: style),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.text,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.textOnPrimary : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
            ],
            Text(text, style: AppTextStyles.title.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

/// Tanlanadigan karta: muddat va mahallar uchun.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.selected,
    required this.onTap,
    required this.title,
    required this.subtitle,
    this.icon,
    this.badge,
  });

  final bool selected;
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.textOnPrimary : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTextStyles.title.copyWith(color: fg),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.textOnPrimary
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge!,
                              style: AppTextStyles.caption.copyWith(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textOnPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.captionSecondary.copyWith(
                        color: selected ? fg : null,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: fg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
