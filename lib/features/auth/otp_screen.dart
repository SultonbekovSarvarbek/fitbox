import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../setup/setup_profile.dart';
import 'auth_service.dart';
import 'phone.dart';
import 'session.dart';
import 'widgets/auth_layout.dart';

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

class OtpArgs {
  const OtpArgs({
    required this.phone,
    required this.purpose,
    required this.resend,
    this.name = '',
  });

  final String phone;
  final OtpPurpose purpose;

  /// Qayta yuborishgacha kutish (soniya).
  final int resend;

  /// Ro'yxatdan o'tishda kiritilgan ism.
  final String name;
}

/// SMS-kodni tasdiqlash. To'g'ri kod: yangi akkaunt → anketa, mavjud akkaunt → Home.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.args});

  final OtpArgs args;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _code = TextEditingController();
  Timer? _timer;
  late int _left = widget.args.resend;
  var _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) t.cancel();
      if (mounted) setState(() => _left = _left > 0 ? _left - 1 : 0);
    });
  }

  Future<void> _resend() async {
    setState(() => _error = null);
    try {
      final wait = await ref
          .read(authRepositoryProvider)
          .requestCode(widget.args.phone, purpose: widget.args.purpose);
      if (!mounted) return;
      setState(() => _left = wait);
      _startTimer();
    } on AuthException {
      if (mounted) setState(() => _error = _sendFailed(context));
    }
  }

  String _sendFailed(BuildContext c) => _t(
    c,
    'Could not send the code. Try again.',
    "Kod yuborilmadi. Qayta urinib ko'ring.",
    'Не удалось отправить код. Попробуйте ещё раз.',
  );

  Future<void> _verify() async {
    if (_busy || _code.text.length != 6) return;
    final a = widget.args;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyCode(a.phone, _code.text);
      if (!mounted) return;
      final prefs = ref.read(sharedPrefsProvider);
      final user = ref.read(userProvider);

      if (a.purpose == OtpPurpose.signup) {
        await Session.register(prefs, a.phone);
        await Session.start(prefs, a.phone);
        ref.read(userProvider.notifier).state = user.copy()
          ..fullName = a.name
          ..phone = a.phone;
        if (mounted) context.go(Routes.setup);
      } else if (Session.setupDone(prefs, a.phone)) {
        await Session.resume(prefs, a.phone);
        if (user.phone.isEmpty) {
          ref.read(userProvider.notifier).state = user.copy()..phone = a.phone;
        }
        if (mounted) context.go(Routes.home);
      } else {
        // Ro'yxatdan o'tgan, lekin anketa tugamagan — davom ettiramiz.
        await Session.start(prefs, a.phone);
        if (mounted) context.go(Routes.setup);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _code.clear();
      setState(() {
        _error = e.error == AuthError.tooManyAttempts
            ? _t(
                context,
                'Too many attempts. Request a new code.',
                "Juda ko'p urinish. Yangi kod so'rang.",
                'Слишком много попыток. Запросите новый код.',
              )
            : _t(
                context,
                'Wrong code. Try again.',
                "Kod noto'g'ri. Qayta urinib ko'ring.",
                'Неверный код. Попробуйте ещё раз.',
              );
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.args;
    return AuthLayout(
      title: _t(context, 'SMS code', 'SMS kod', 'Код из SMS'),
      subtitle: _t(
        context,
        'We sent a 6-digit code to ${formatPhone(a.phone)}',
        "${formatPhone(a.phone)} raqamiga 6 xonali kod yubordik",
        'Мы отправили 6-значный код на ${formatPhone(a.phone)}',
      ),
      fields: [
        TextField(
          controller: _code,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          cursorColor: AppColors.primary,
          style: AppTextStyles.h1.copyWith(letterSpacing: 12),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: const InputDecoration(hintText: '······'),
          onChanged: (v) {
            if (_error != null) setState(() => _error = null);
            if (v.length == 6) _verify();
          },
        ),
        if (_error != null)
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.orange,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _t(
                  context,
                  'Demo: no SMS is sent — use code ${DemoAuthRepository.demoCode}.',
                  "Demo: SMS yuborilmaydi — ${DemoAuthRepository.demoCode} kodini kiriting.",
                  'Демо: SMS не отправляется — введите код ${DemoAuthRepository.demoCode}.',
                ),
                style: AppTextStyles.caption.copyWith(color: AppColors.orange),
              ),
            ),
          ],
        ),
      ],
      action: PrimaryButton(
        label: _t(context, 'Confirm', 'Tasdiqlash', 'Подтвердить'),
        expanded: true,
        loading: _busy,
        onPressed: _code.text.length == 6 ? _verify : null,
      ),
      footer: Column(
        children: [
          if (_left > 0)
            Text(
              _t(
                context,
                'Resend code in $_left s',
                "Kodni qayta yuborish: $_left s",
                'Отправить код повторно через $_left с',
              ),
              style: AppTextStyles.captionSecondary,
            )
          else
            TextButton(
              onPressed: _resend,
              child: Text(
                _t(
                  context,
                  'Resend code',
                  'Kodni qayta yuborish',
                  'Отправить код ещё раз',
                ),
              ),
            ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              _t(
                context,
                'Change number',
                "Raqamni o'zgartirish",
                'Изменить номер',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
