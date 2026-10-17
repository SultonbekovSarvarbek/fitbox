import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import 'data/market_models.dart';
import 'data/subscription_models.dart';
import 'subscribe_screen.dart' show formatDate;
import 'widgets/checkout_sheet.dart' show PaymentL10n;

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

enum _Stage { choose, processing, done }

/// Obuna to'lovi. DEMO: pul yechilmaydi — to'lov bosqichlari (usul tanlash →
/// Payme/Click'ga o'tish → kutish → tasdiq) ko'rsatiladi, obuna esa telefonga yoziladi.
/// TODO(backend): Payme/Click to'lov havolasi, webhook orqali tasdiq, obuna serverda.
class SubscriptionPaymentScreen extends ConsumerStatefulWidget {
  const SubscriptionPaymentScreen({super.key, required this.draft});

  final SubscriptionDraft draft;

  @override
  ConsumerState<SubscriptionPaymentScreen> createState() =>
      _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState
    extends ConsumerState<SubscriptionPaymentScreen> {
  var _method = PaymentMethod.payme;
  var _stage = _Stage.choose;
  Subscription? _created;

  Future<void> _pay() async {
    setState(() => _stage = _Stage.processing);
    // Haqiqiy to'lov provayderi javobini kutishni taqlid qiladi.
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final d = widget.draft;
    final sub = Subscription(
      id: 'SUB-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      createdAt: DateTime.now(),
      planId: d.planId,
      months: d.months,
      slots: d.slots,
      startDate: d.startDate,
      address: d.address,
      phone: d.phone,
      total: d.total,
      payment: _method,
    );
    ref.read(subscriptionsProvider.notifier).add(sub);
    HapticFeedback.heavyImpact();
    setState(() {
      _created = sub;
      _stage = _Stage.done;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // To'lov jarayonida orqaga qaytib bo'lmaydi.
      canPop: _stage == _Stage.choose,
      child: Scaffold(
        appBar: _stage == _Stage.done
            ? null
            : AppBar(
                automaticallyImplyLeading: _stage == _Stage.choose,
                title: Text(_t(context, 'Payment', "To'lov", 'Оплата')),
              ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: switch (_stage) {
              _Stage.choose => _choose(context),
              _Stage.processing => _processing(context),
              _Stage.done => _done(context),
            },
          ),
        ),
      ),
    );
  }

  Widget _choose(BuildContext context) {
    final d = widget.draft;
    final price = subscriptionPrice(
      d.plan,
      months: d.months,
      slots: d.slots.length,
    );
    return ListView(
      key: const ValueKey('choose'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(kitchenName, style: AppTextStyles.captionSecondary),
              Text(d.plan.title.of(context), style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${d.months == 1 ? _t(context, '1 month', '1 oy', '1 месяц') : _t(context, '3 months', '3 oy', '3 месяца')} · '
                '${d.slots.map((s) => s.label.of(context)).join(', ')}',
                style: AppTextStyles.body,
              ),
              Text(
                '${_t(context, 'Starts', 'Boshlanishi', 'Старт')}: ${formatDate(context, d.startDate)}',
                style: AppTextStyles.bodySecondary,
              ),
              Text(d.address, style: AppTextStyles.bodySecondary),
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  Text(context.l10n.total, style: AppTextStyles.title),
                  const Spacer(),
                  Text(
                    formatSum(context, price.total),
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(context.l10n.paymentMethod, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        for (final m in PaymentMethod.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              color: _method == m ? AppColors.surfaceLight : AppColors.surface,
              onTap: () => setState(() => _method = m),
              child: Row(
                children: [
                  Icon(m.icon, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.label(context), style: AppTextStyles.title),
                        Text(switch (m) {
                          PaymentMethod.payme => _t(
                            context,
                            'Pay in the Payme app',
                            "Payme ilovasida to'lang",
                            'Оплата в приложении Payme',
                          ),
                          PaymentMethod.click => _t(
                            context,
                            'Pay in the Click app',
                            "Click ilovasida to'lang",
                            'Оплата в приложении Click',
                          ),
                          PaymentMethod.cash => _t(
                            context,
                            'Pay the courier at the first delivery',
                            "Birinchi yetkazishda kuryerga to'lang",
                            'Оплата курьеру при первой доставке',
                          ),
                        }, style: AppTextStyles.captionSecondary),
                      ],
                    ),
                  ),
                  Icon(
                    _method == m
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _method == m
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _t(
                  context,
                  'Demo: no money is charged and nothing is sent anywhere.',
                  "Demo: pul yechilmaydi va hech qayerga yuborilmaydi.",
                  'Демо: деньги не списываются и ничего никуда не отправляется.',
                ),
                style: AppTextStyles.caption.copyWith(color: AppColors.orange),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: _method == PaymentMethod.cash
              ? _t(
                  context,
                  'Confirm subscription',
                  'Obunani tasdiqlash',
                  'Подтвердить подписку',
                )
              : '${_t(context, 'Pay', "To'lash", 'Оплатить')} · ${formatSum(context, price.total)}',
          icon: Icons.lock_outline_rounded,
          expanded: true,
          onPressed: _pay,
        ),
      ],
    );
  }

  Widget _processing(BuildContext context) {
    final redirect = _method != PaymentMethod.cash;
    return Center(
      key: const ValueKey('processing'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              redirect
                  ? _t(
                      context,
                      'Waiting for ${_method.label(context)}…',
                      '${_method.label(context)} javobi kutilmoqda…',
                      'Ожидаем ответ ${_method.label(context)}…',
                    )
                  : _t(
                      context,
                      'Creating subscription…',
                      'Obuna yaratilmoqda…',
                      'Создаём подписку…',
                    ),
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _done(BuildContext context) {
    final s = _created!;
    final cash = s.payment == PaymentMethod.cash;
    return Padding(
      key: const ValueKey('done'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 64,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _t(
              context,
              'Subscription is active',
              'Obuna faollashdi',
              'Подписка активна',
            ),
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${_t(context, 'First delivery', 'Birinchi yetkazish', 'Первая доставка')}: ${formatDate(context, s.startDate)}',
            style: AppTextStyles.body,
          ),
          Text(
            cash
                ? _t(
                    context,
                    'Pay the courier on the first delivery.',
                    "Birinchi yetkazishda kuryerga to'laysiz.",
                    'Оплата курьеру при первой доставке.',
                  )
                : '${_t(context, 'Paid', "To'landi", 'Оплачено')}: ${formatSum(context, s.total)} · ${s.payment.label(context)}',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('${s.id} · demo', style: AppTextStyles.captionSecondary),
          const Spacer(),
          PrimaryButton(
            label: _t(
              context,
              'My subscription',
              'Mening obunam',
              'Моя подписка',
            ),
            expanded: true,
            onPressed: () => context.go(Routes.subscription),
          ),
        ],
      ),
    );
  }
}
