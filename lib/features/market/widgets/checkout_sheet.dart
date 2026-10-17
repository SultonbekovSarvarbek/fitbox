import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../setup/setup_profile.dart';
import '../data/market_models.dart';

extension PaymentL10n on PaymentMethod {
  String label(BuildContext context) => switch (this) {
    PaymentMethod.payme => 'Payme',
    PaymentMethod.click => 'Click',
    PaymentMethod.cash => context.l10n.cashOnDelivery,
  };

  IconData get icon => switch (this) {
    PaymentMethod.payme || PaymentMethod.click => Icons.credit_card_rounded,
    PaymentMethod.cash => Icons.payments_rounded,
  };
}

/// Buyurtmani rasmiylashtirish: manzil, telefon, to'lov turi → tasdiq.
/// Buyurtma berilsa `true`. DEMO: hech qayerga yuborilmaydi, faqat tarixga yoziladi.
Future<bool> showCheckout(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required int total,
}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CheckoutSheet(title: title, total: total),
  );
  return ok ?? false;
}

class _CheckoutSheet extends ConsumerStatefulWidget {
  const _CheckoutSheet({required this.title, required this.total});

  final String title;
  final int total;

  @override
  ConsumerState<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<_CheckoutSheet> {
  final _form = GlobalKey<FormState>();
  final _address = TextEditingController();
  late final _phone = TextEditingController(text: ref.read(userProvider).phone);
  var _payment = PaymentMethod.payme;
  var _done = false;

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    ref
        .read(ordersProvider.notifier)
        .add(
          Order(
            id: 'ORD-${DateTime.now().millisecondsSinceEpoch % 1000000}',
            date: DateTime.now(),
            title: widget.title,
            total: widget.total,
            payment: _payment,
            address: _address.text.trim(),
          ),
        );
    HapticFeedback.heavyImpact();
    setState(() => _done = true);
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _done ? _success(context) : _formView(context),
      ),
    );
  }

  Widget _success(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const ValueKey('done'),
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 56,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.orderPlaced,
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.orderDemoNote,
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: l10n.close,
          expanded: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }

  Widget _formView(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        key: const ValueKey('form'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.checkout, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(widget.title, style: AppTextStyles.bodySecondary, maxLines: 2),
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
            hint: '+998 __ ___ __ __',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                (v == null || v.replaceAll(RegExp(r'\D'), '').length < 9)
                ? context.l10n.fieldRequired
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.paymentMethod,
            style: AppTextStyles.captionSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final m in PaymentMethod.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _payment = m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _payment == m
                              ? AppColors.primary
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              m.icon,
                              color: _payment == m
                                  ? AppColors.textOnPrimary
                                  : AppColors.textPrimary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m.label(context),
                              style: AppTextStyles.caption.copyWith(
                                color: _payment == m
                                    ? AppColors.textOnPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            color: AppColors.surfaceLight,
            child: Row(
              children: [
                Text(context.l10n.total, style: AppTextStyles.title),
                const Spacer(),
                Text(
                  formatSum(context, widget.total),
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: context.l10n.placeOrder,
            icon: Icons.shopping_bag_rounded,
            expanded: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
