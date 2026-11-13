import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';

enum PillTone { soft, outline, sage, ochre, ember, ghost }

/// Small rounded badge/chip used everywhere in the design
/// (e.g. "✦ FOUNDATION", "+18% vs last wk", "7d streak").
class AppPill extends StatelessWidget {
  const AppPill(
    this.label, {
    super.key,
    this.tone = PillTone.soft,
    this.icon,
    this.leading,
    this.trailing,
    this.textStyle,
    this.padding,
    this.onTap,
  });

  final String label;
  final PillTone tone;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    late Color bg;
    late Color fg;
    Border? border;

    switch (tone) {
      case PillTone.soft:
        bg = isDark ? p.panel : p.panel;
        fg = isDark ? p.body : p.body;
        border = Border.all(color: isDark ? p.bone : p.container);
      case PillTone.outline:
        bg = Colors.transparent;
        fg = isDark ? p.body : p.body;
        border = Border.all(color: isDark ? p.bone : p.container);
      case PillTone.sage:
        bg = isDark ? p.pineDark.withValues(alpha: 0.35) : p.mintSoft;
        fg = isDark ? p.success : p.pineDark;
      case PillTone.ochre:
        bg = isDark ? p.ochre.withValues(alpha: 0.22) : p.goldSoft;
        fg = isDark ? p.gold : p.ochre;
      case PillTone.ember:
        bg = p.ember.withValues(alpha: isDark ? 0.18 : 0.10);
        fg = isDark ? p.emberDeep : p.emberDeep;
      case PillTone.ghost:
        bg = Colors.transparent;
        fg = isDark ? p.muted : p.muted;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.s4)],
        if (icon != null) ...[
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: AppSpacing.s4),
        ],
        Text(
          label,
          style: (textStyle ?? AppText.interactiveLabel).copyWith(color: fg),
        ),
        if (trailing != null) ...[const SizedBox(width: AppSpacing.s4), trailing!],
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: border,
        ),
        child: content,
      ),
    );
  }
}
