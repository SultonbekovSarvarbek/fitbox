import 'package:flutter/widgets.dart';

import '../../core/locale/locale_provider.dart';

abstract final class Validators {
  static FormFieldValidator<String> required(BuildContext context) =>
      (v) =>
          (v == null || v.trim().isEmpty) ? context.l10n.fieldRequired : null;

  static FormFieldValidator<String> email(BuildContext context) => (v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : context.l10n.invalidEmail;
  };

  static FormFieldValidator<String> password(BuildContext context) => (v) {
    if (v == null || v.isEmpty) return context.l10n.fieldRequired;
    return v.length < 6 ? context.l10n.passwordTooShort : null;
  };
}
