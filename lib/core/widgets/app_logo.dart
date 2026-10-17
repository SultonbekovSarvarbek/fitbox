import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// TODO(design): haqiqiy logotip SVG bo'lsa — almashtiring.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.bolt_rounded,
            size: size * 0.6,
            color: AppColors.textOnPrimary,
          ),
        ),
        SizedBox(height: size * 0.2),
        Text(
          'FITBODY',
          style: AppTextStyles.display.copyWith(fontSize: size * 0.4),
        ),
      ],
    );
  }
}
