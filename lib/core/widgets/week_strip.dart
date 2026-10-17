import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Hafta kunlari qatori: M T W T F S S + sanalar, tanlangani lime doira.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.selected, required this.onSelect});

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final monday = selected.subtract(Duration(days: selected.weekday - 1));
    final days = [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final d in days)
          GestureDetector(
            onTap: () => onSelect(d),
            child: Column(
              children: [
                Text(
                  DateFormat.E(locale).format(d).substring(0, 1).toUpperCase(),
                  style: AppTextStyles.captionSecondary,
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DateUtils.isSameDay(d, selected)
                        ? AppColors.primary
                        : AppColors.surface,
                  ),
                  child: Text(
                    '${d.day}',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 13,
                      color: DateUtils.isSameDay(d, selected)
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
