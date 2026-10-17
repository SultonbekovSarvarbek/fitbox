import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/content/content_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_service.dart';
import 'otp_screen.dart';
import 'phone.dart';
import 'widgets/auth_layout.dart';

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

/// Telefon maydoni uchun: faqat raqamlar, 9 tagacha (+998 oldindan turadi).
final phoneFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(9),
];

String? phoneValidator(BuildContext context, String? v) =>
    normalizePhone(v ?? '') == null
    ? _t(
        context,
        'Enter 9 digits of your number',
        "Raqamning 9 ta raqamini kiriting",
        'Введите 9 цифр номера',
      )
    : null;

/// 3. Kirish: telefon → SMS kod.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  var _loading = false;
  String? _error;
  var _notFound = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _notFound = false;
    });
    if (!_formKey.currentState!.validate()) return;
    final phone = normalizePhone(_phone.text)!;
    setState(() => _loading = true);
    try {
      final wait = await ref
          .read(authRepositoryProvider)
          .requestCode(phone, purpose: OtpPurpose.login);
      if (!mounted) return;
      context.push(
        Routes.otp,
        extra: OtpArgs(phone: phone, purpose: OtpPurpose.login, resend: wait),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _notFound = e.error == AuthError.accountNotFound;
        _error = _notFound
            ? _t(
                context,
                'No account with this number yet.',
                "Bu raqam bilan akkaunt topilmadi.",
                'Аккаунта с таким номером нет.',
              )
            : _t(
                context,
                'Could not send the code. Try again.',
                "Kod yuborilmadi. Qayta urinib ko'ring.",
                'Не удалось отправить код. Попробуйте ещё раз.',
              );
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthLayout(
        title: _t(context, 'Log in', 'Kirish', 'Вход'),
        subtitle: _t(
          context,
          "Enter your phone number — we'll send an SMS code.",
          "Telefon raqamingizni kiriting — SMS kod yuboramiz.",
          'Введите номер телефона — отправим SMS с кодом.',
        ),
        fields: [
          AppTextField(
            label: _t(
              context,
              'Phone number',
              'Telefon raqam',
              'Номер телефона',
            ),
            controller: _phone,
            hint: '90 123 45 67',
            prefixText: '+998 ',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: phoneFormatters,
            autofocus: true,
            validator: (v) => phoneValidator(context, v),
          ),
          if (_error != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    _error!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                if (_notFound)
                  TextButton(
                    onPressed: () => context.pushReplacement(Routes.signup),
                    child: Text(
                      _t(
                        context,
                        'Sign up',
                        "Ro'yxatdan o'tish",
                        'Регистрация',
                      ),
                    ),
                  ),
              ],
            ),
        ],
        action: PrimaryButton(
          label: _t(context, 'Get code', 'Kod olish', 'Получить код'),
          expanded: true,
          loading: _loading,
          onPressed: _loading ? null : _submit,
        ),
        footer: AuthSwitchRow(
          text: _t(
            context,
            "Don't have an account?",
            "Akkauntingiz yo'qmi?",
            'Нет аккаунта?',
          ),
          action: _t(context, 'Sign up', "Ro'yxatdan o'tish", 'Регистрация'),
          onTap: () => context.pushReplacement(Routes.signup),
        ),
      ),
    );
  }
}
