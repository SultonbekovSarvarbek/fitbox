import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_service.dart';
import 'login_screen.dart' show phoneFormatters, phoneValidator;
import 'otp_screen.dart';
import 'phone.dart';
import 'validators.dart';
import 'widgets/auth_layout.dart';

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

/// Ro'yxatdan o'tish: ism + telefon + shartlarga rozilik → SMS kod → anketa.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  var _agreed = false;
  var _showAgreeError = false;
  var _loading = false;
  String? _error;
  var _exists = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _exists = false;
      _showAgreeError = !_agreed;
    });
    if (!_formKey.currentState!.validate() || !_agreed) return;
    final phone = normalizePhone(_phone.text)!;
    setState(() => _loading = true);
    try {
      final wait = await ref
          .read(authRepositoryProvider)
          .requestCode(phone, purpose: OtpPurpose.signup);
      if (!mounted) return;
      context.push(
        Routes.otp,
        extra: OtpArgs(
          phone: phone,
          purpose: OtpPurpose.signup,
          resend: wait,
          name: _name.text.trim(),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _exists = e.error == AuthError.accountExists;
        _error = _exists
            ? _t(
                context,
                'This number is already registered.',
                "Bu raqam allaqachon ro'yxatdan o'tgan.",
                'Этот номер уже зарегистрирован.',
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
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: AuthLayout(
        title: _t(context, 'Sign up', "Ro'yxatdan o'tish", 'Регистрация'),
        subtitle: _t(
          context,
          "Tell us your name and number — we'll confirm it with an SMS code.",
          "Ismingiz va raqamingizni kiriting — SMS kod bilan tasdiqlaymiz.",
          'Укажите имя и номер — подтвердим SMS-кодом.',
        ),
        fields: [
          AppTextField(
            label: l10n.fullName,
            controller: _name,
            prefixIcon: Icons.person_outline_rounded,
            validator: Validators.required(context),
          ),
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
                if (_exists)
                  TextButton(
                    onPressed: () => context.pushReplacement(Routes.login),
                    child: Text(_t(context, 'Log in', 'Kirish', 'Войти')),
                  ),
              ],
            ),
          InkWell(
            onTap: () => setState(() {
              _agreed = !_agreed;
              _showAgreeError = false;
            }),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreed,
                  activeColor: AppColors.primary,
                  checkColor: AppColors.textOnPrimary,
                  onChanged: (v) => setState(() {
                    _agreed = v ?? false;
                    _showAgreeError = false;
                  }),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _t(
                        context,
                        'I agree to the terms of use and the privacy policy',
                        "Foydalanish shartlari va maxfiylik siyosatiga roziman",
                        'Я согласен(на) с условиями использования и политикой конфиденциальности',
                      ),
                      style: AppTextStyles.caption.copyWith(
                        color: _showAgreeError
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        action: PrimaryButton(
          label: _t(context, 'Get code', 'Kod olish', 'Получить код'),
          expanded: true,
          loading: _loading,
          onPressed: _submit,
        ),
        footer: AuthSwitchRow(
          text: l10n.alreadyHaveAccount,
          action: l10n.logIn,
          onTap: () => context.pushReplacement(Routes.login),
        ),
      ),
    );
  }
}
