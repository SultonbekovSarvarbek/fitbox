import 'package:flutter/material.dart';
import '../progress/data/progress_models.dart';
import 'widgets/user_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../setup/setup_profile.dart';

/// 6.1.1 Edit Profile.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final _user = ref.read(userProvider);
  late final _name = TextEditingController(text: _user.fullName);
  late final _nickname = TextEditingController(text: _user.nickname);
  late final _email = TextEditingController(text: _user.email);
  late final _phone = TextEditingController(text: _user.phone);
  late final _weight = TextEditingController(text: '${_user.weightKg}');
  late final _height = TextEditingController(text: '${_user.heightCm}');
  late final _age = TextEditingController(text: '${_user.age}');

  @override
  void dispose() {
    for (final c in [
      _name,
      _nickname,
      _email,
      _phone,
      _weight,
      _height,
      _age,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final newWeight = int.tryParse(_weight.text);
    ref.read(userProvider.notifier).state = _user.copy()
      ..avatarPath = ref.read(userProvider).avatarPath
      ..fullName = _name.text.trim()
      ..nickname = _nickname.text.trim()
      ..email = _email.text.trim()
      ..phone = _phone.text.trim()
      ..weightKg = int.tryParse(_weight.text) ?? _user.weightKg
      ..heightCm = int.tryParse(_height.text) ?? _user.heightCm
      ..age = int.tryParse(_age.text) ?? _user.age;
    if (newWeight != null && newWeight != _user.weightKg) {
      ref.read(weightLogProvider.notifier).add(newWeight.toDouble());
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.saved)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const gap = SizedBox(height: AppSpacing.md);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Center(child: UserAvatar(editable: true, ring: true)),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: l10n.fullName,
            controller: _name,
            prefixIcon: Icons.person_outline_rounded,
          ),
          gap,
          AppTextField(
            label: l10n.nickname,
            controller: _nickname,
            prefixIcon: Icons.alternate_email_rounded,
          ),
          gap,
          AppTextField(
            label: l10n.email,
            controller: _email,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          gap,
          AppTextField(
            label: l10n.mobileNumber,
            controller: _phone,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          gap,
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: '${l10n.weightProgress}, ${l10n.kg}',
                  controller: _weight,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: '${l10n.heightLabel}, ${l10n.cm}',
                  controller: _height,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: l10n.ageLabel,
                  controller: _age,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: l10n.saveRoutine,
            expanded: true,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
