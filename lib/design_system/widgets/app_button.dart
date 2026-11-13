import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_colors.dart';
import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';

enum AppButtonVariant { primary, soft, ghost }

/// The "Trigger" button family from the design system.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.expand = true,
    this.height = AppSizes.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null;

    late Color bg;
    late Color fg;
    Border? border;
    List<BoxShadow>? shadow;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.sparkOrange;
        fg = Colors.white;
        shadow = [
          BoxShadow(
            color: AppColors.sparkOrange.withValues(alpha: isDark ? 0.28 : 0.32),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ];
      case AppButtonVariant.soft:
        bg = isDark ? AppColors.darkSurfaceHigh : AppColors.warmBone;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.onBackground;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;
        border = Border.all(color: isDark ? AppColors.darkOutline : AppColors.surfaceContainer);
    }

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.btn),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.btn),
          child: Container(
            height: height,
            width: expand ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: expand ? AppSpacing.s16 : AppSpacing.s20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.btn),
              border: border,
              boxShadow: shadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: AppSpacing.s8),
                ],
                Text(label, style: AppText.buttonLabel.copyWith(color: fg)),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.s8),
                  Icon(trailingIcon, size: 18, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
