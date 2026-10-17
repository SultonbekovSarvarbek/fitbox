import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'data/market_models.dart';
import 'data/subscription_models.dart';
import 'subscribe_screen.dart' show formatDate;
import 'widgets/checkout_sheet.dart' show PaymentL10n;

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

/// Obuna holati yorlig'i va rangi (Obuna tabi va profilda ham ishlatiladi).
(String, Color) subscriptionStatusInfo(BuildContext context, Subscription s) {
  final now = DateTime.now();
  return switch (s.statusAt(now)) {
    SubscriptionStatus.active => (
      s.hasPause(now) && s.pauseFrom != null
          ? _t(
              context,
              'Active · pause from ${formatDate(context, s.pauseFrom!)}',
              "Faol · pauza ${formatDate(context, s.pauseFrom!)} dan",
              'Активна · пауза с ${formatDate(context, s.pauseFrom!)}',
            )
          : _t(context, 'Active', 'Faol', 'Активна'),
      AppColors.primary,
    ),
    SubscriptionStatus.upcoming => (
      _t(
        context,
        'Starts ${formatDate(context, s.startDate)}',
        "${formatDate(context, s.startDate)} dan boshlanadi",
        'Начнётся ${formatDate(context, s.startDate)}',
      ),
      AppColors.purple,
    ),
    SubscriptionStatus.paused => (
      _t(
        context,
        'Paused until ${formatDate(context, s.pauseUntil!)}',
        "Pauza: ${formatDate(context, s.pauseUntil!)} gacha",
        'Пауза до ${formatDate(context, s.pauseUntil!)}',
      ),
      AppColors.orange,
    ),
    SubscriptionStatus.ended => (
      _t(context, 'Ended', 'Tugagan', 'Завершена'),
      AppColors.textSecondary,
    ),
    SubscriptionStatus.canceled => (
      _t(context, 'Canceled', 'Bekor qilingan', 'Отменена'),
      AppColors.error,
    ),
  };
}

/// Obunani boshqarish: pauza, qayta boshlash, manzil, bekor qilish.
class SubscriptionDetailScreen extends ConsumerWidget {
  const SubscriptionDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref
        .watch(subscriptionsProvider)
        .where((e) => e.id == id)
        .firstOrNull;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            _t(
              context,
              'Subscription not found',
              'Obuna topilmadi',
              'Подписка не найдена',
            ),
            style: AppTextStyles.bodySecondary,
          ),
        ),
      );
    }

    final now = DateTime.now();
    final (statusText, statusColor) = subscriptionStatusInfo(context, s);
    final notifier = ref.read(subscriptionsProvider.notifier);

    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(k, style: AppTextStyles.captionSecondary),
          ),
          Expanded(child: Text(v, style: AppTextStyles.body)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t(context, 'My subscription', 'Mening obunam', 'Моя подписка'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(kitchenName, style: AppTextStyles.captionSecondary),
                Text(
                  s.plan?.title.of(context) ?? s.planId,
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: AppSpacing.md),
                row(
                  _t(context, 'Period', 'Davr', 'Период'),
                  '${formatDate(context, s.startDate)} — ${formatDate(context, s.endDate)}',
                ),
                if (s.pausedDays > 0)
                  row(
                    _t(context, 'Paused days', 'Pauza kunlari', 'Дней паузы'),
                    '${s.pausedDays} (${_t(context, 'added to the end', "oxiriga qo'shildi", 'добавлены в конец')})',
                  ),
                row(
                  _t(context, 'Meals', 'Mahallar', 'Приёмы'),
                  s.slots
                      .map((m) => '${m.label.of(context)} ${m.window}')
                      .join('\n'),
                ),
                row(_t(context, 'Address', 'Manzil', 'Адрес'), s.address),
                row(context.l10n.mobileNumber, s.phone),
                row(
                  _t(context, 'Paid', "To'lov", 'Оплата'),
                  '${formatSum(context, s.total)} · ${s.payment.label(context)}',
                ),
                row('ID', s.id),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (s.isLive) ...[
            if (s.hasPause(now))
              PrimaryButton(
                label: _t(
                  context,
                  'Resume meals',
                  'Ovqatni qayta boshlash',
                  'Возобновить питание',
                ),
                icon: Icons.play_arrow_rounded,
                expanded: true,
                onPressed: () {
                  notifier.replace(s.resumed(DateTime.now()));
                  _snack(
                    context,
                    _t(
                      context,
                      'Deliveries resume tomorrow',
                      'Yetkazish ertadan qayta boshlanadi',
                      'Доставка возобновится завтра',
                    ),
                  );
                },
              )
            else
              PrimaryButton(
                label: _t(
                  context,
                  'Pause meals',
                  'Ovqatni to\'xtatish',
                  'Приостановить питание',
                ),
                icon: Icons.pause_rounded,
                expanded: true,
                onPressed: () => _pause(context, s, notifier),
              ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: _t(
                context,
                'Change address',
                "Manzilni o'zgartirish",
                'Изменить адрес',
              ),
              icon: Icons.edit_location_alt_outlined,
              variant: ButtonVariant.secondary,
              expanded: true,
              onPressed: () => _editDelivery(context, s, notifier),
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: _t(
                context,
                'Cancel subscription',
                'Obunani bekor qilish',
                'Отменить подписку',
              ),
              variant: ButtonVariant.outline,
              expanded: true,
              onPressed: () => _cancel(context, s, notifier),
            ),
          ] else if (s.plan != null)
            PrimaryButton(
              label: _t(
                context,
                'Subscribe again',
                'Qayta obuna bo\'lish',
                'Оформить снова',
              ),
              expanded: true,
              onPressed: () => context.push(Routes.subscribe(s.planId)),
            ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pause(
    BuildContext context,
    Subscription s,
    SubscriptionsNotifier notifier,
  ) async {
    final days = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t(
                  context,
                  'Pause for how long?',
                  'Qancha muddatga to\'xtatamiz?',
                  'На сколько приостановить?',
                ),
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 4),
              Text(
                _t(
                  context,
                  'The courier stops from tomorrow. The paused days are added to the end of your subscription — you lose nothing.',
                  "Kuryer ertadan to'xtaydi. Pauza kunlari obuna oxiriga qo'shiladi — hech narsa yo'qolmaydi.",
                  'Курьер перестанет приезжать с завтрашнего дня. Дни паузы добавятся в конец подписки — вы ничего не теряете.',
                ),
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final d in const [3, 7, 14])
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: PrimaryButton(
                    label: _t(context, '$d days', '$d kun', '$d дн.'),
                    variant: ButtonVariant.secondary,
                    expanded: true,
                    onPressed: () => Navigator.pop(ctx, d),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (days == null || !context.mounted) return;
    final p = s.paused(days, DateTime.now());
    notifier.replace(p);
    _snack(
      context,
      _t(
        context,
        'Paused until ${formatDate(context, p.pauseUntil!)}',
        "Pauza: ${formatDate(context, p.pauseUntil!)} gacha",
        'Пауза до ${formatDate(context, p.pauseUntil!)}',
      ),
    );
  }

  Future<void> _editDelivery(
    BuildContext context,
    Subscription s,
    SubscriptionsNotifier notifier,
  ) async {
    final saved = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DeliverySheet(address: s.address, phone: s.phone),
    );
    if (saved == null) return;
    notifier.replace(s.withDelivery(address: saved.$1, phone: saved.$2));
  }

  Future<void> _cancel(
    BuildContext context,
    Subscription s,
    SubscriptionsNotifier notifier,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          _t(
            context,
            'Cancel subscription?',
            'Obuna bekor qilinsinmi?',
            'Отменить подписку?',
          ),
          style: AppTextStyles.h3,
        ),
        content: Text(
          _t(
            context,
            'Deliveries stop from tomorrow. Consider a pause instead — you keep the paid days. In this demo no refund is made.',
            "Yetkazish ertadan to'xtaydi. Pauza qilish yaxshiroq — to'langan kunlar saqlanadi. Demoda pul qaytarilmaydi.",
            'Доставка прекратится с завтрашнего дня. Подумайте о паузе — оплаченные дни сохранятся. В демо возврат денег не выполняется.',
          ),
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              _t(context, 'Keep it', 'Qoldirish', 'Оставить'),
              style: AppTextStyles.title,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              _t(
                context,
                'Cancel subscription',
                'Bekor qilish',
                'Отменить подписку',
              ),
              style: AppTextStyles.title.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    notifier.replace(s.canceled(DateTime.now()));
  }
}

/// Manzil va telefonni o'zgartirish. Maydonlar shu vidjetning o'zida yashaydi —
/// oyna yopilish animatsiyasi tugamasdan turib dispose bo'lib qolmasin.
class _DeliverySheet extends StatefulWidget {
  const _DeliverySheet({required this.address, required this.phone});

  final String address;
  final String phone;

  @override
  State<_DeliverySheet> createState() => _DeliverySheetState();
}

class _DeliverySheetState extends State<_DeliverySheet> {
  final _form = GlobalKey<FormState>();
  late final _address = TextEditingController(text: widget.address);
  late final _phone = TextEditingController(text: widget.phone);

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _t(
                context,
                'Delivery details',
                "Yetkazish ma'lumotlari",
                'Данные доставки',
              ),
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.md),
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
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.replaceAll(RegExp(r'\D'), '').length < 9)
                  ? context.l10n.fieldRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: _t(context, 'Save', 'Saqlash', 'Сохранить'),
              expanded: true,
              onPressed: () {
                if (_form.currentState!.validate()) {
                  Navigator.pop(context, (
                    _address.text.trim(),
                    _phone.text.trim(),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
