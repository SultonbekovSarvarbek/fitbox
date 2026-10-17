import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Yosh / vazn / bo'y uchun aylanuvchi raqam tanlagich.
class WheelPicker extends StatefulWidget {
  const WheelPicker({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.unit,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;
  final String? unit;

  @override
  State<WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker> {
  late final _controller = FixedExtentScrollController(
    initialItem: widget.value - widget.min,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 76,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 76,
            diameterRatio: 1.6,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) => widget.onChanged(widget.min + i),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.max - widget.min + 1,
              builder: (_, i) {
                final v = widget.min + i;
                final selected = v == widget.value;
                return Center(
                  child: Text.rich(
                    TextSpan(
                      text: '$v',
                      children: [
                        if (selected && widget.unit != null)
                          TextSpan(
                            text: ' ${widget.unit}',
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                      ],
                    ),
                    style: AppTextStyles.h1.copyWith(
                      fontSize: selected ? 44 : 30,
                      color: selected
                          ? AppColors.textOnPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
