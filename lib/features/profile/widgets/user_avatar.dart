import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../setup/setup_profile.dart';

/// Foydalanuvchi avatari. `editable` bo'lsa — bosganda kamera / galereya / o'chirish.
/// Rasm ilova papkasiga ko'chiriladi va yo'li saqlanadi (ilova qayta ochilganda ham turadi).
/// TODO(backend): serverga yuklash.
class UserAvatar extends ConsumerWidget {
  const UserAvatar({
    super.key,
    this.radius = 52,
    this.editable = false,
    this.ring = false,
    this.onTap,
  });

  final double radius;
  final bool editable;

  /// Atrofida lime halqa (Profil sahifasidagidek).
  final bool ring;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(userProvider.select((u) => u.avatarPath));
    final file = path == null ? null : File(path);
    final hasImage = file != null && file.existsSync();

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surfaceLight,
      foregroundImage: hasImage ? FileImage(file) : null,
      child: Icon(
        Icons.person_rounded,
        size: radius * 1.1,
        color: AppColors.textSecondary,
      ),
    );

    if (ring) {
      avatar = Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: avatar,
      );
    }

    if (editable) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(radius * 0.12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 3),
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                size: radius * 0.32,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: editable ? () => _showPicker(context, ref, hasImage) : onTap,
      child: avatar,
    );
  }

  Future<void> _showPicker(
    BuildContext context,
    WidgetRef ref,
    bool hasImage,
  ) async {
    final l10n = context.l10n;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.profilePhoto, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              _SheetItem(
                icon: Icons.photo_camera_rounded,
                label: l10n.takePhoto,
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              _SheetItem(
                icon: Icons.photo_library_rounded,
                label: l10n.chooseFromGallery,
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              if (hasImage)
                _SheetItem(
                  icon: Icons.delete_outline_rounded,
                  label: l10n.removePhoto,
                  color: AppColors.error,
                  onTap: () => Navigator.pop(ctx, 'remove'),
                ),
            ],
          ),
        ),
      ),
    );

    switch (action) {
      case 'camera':
        await _pick(ref, ImageSource.camera);
      case 'gallery':
        await _pick(ref, ImageSource.gallery);
      case 'remove':
        await _set(ref, null);
    }
  }

  static Future<void> _pick(WidgetRef ref, ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    // Har safar yangi nom — Image keshi eski rasmni ko'rsatib qolmasligi uchun.
    final target =
        '${dir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(picked.path).copy(target);
    await _set(ref, target);
  }

  static Future<void> _set(WidgetRef ref, String? path) async {
    final old = ref.read(userProvider).avatarPath;
    ref.read(userProvider.notifier).state = ref.read(userProvider).copy()
      ..avatarPath = path;
    final prefs = ref.read(sharedPrefsProvider);
    if (path == null) {
      await prefs.remove(avatarPrefsKey);
    } else {
      await prefs.setString(avatarPrefsKey, path);
    }
    if (old != null && old != path) {
      try {
        await File(old).delete();
      } catch (_) {}
    }
  }
}

class _SheetItem extends StatelessWidget {
  const _SheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceLight,
        child: Icon(
          icon,
          color: color == AppColors.textPrimary ? AppColors.primary : color,
        ),
      ),
      title: Text(label, style: AppTextStyles.title.copyWith(color: color)),
    );
  }
}
