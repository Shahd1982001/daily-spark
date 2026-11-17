import 'package:flutter/material.dart';
import 'package:daily_spark/l10n/strings.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Profile · a labelled group of settings rows (Figma: label + white r16 card).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.scale,
    required this.label,
    required this.rows,
  });

  final double scale;
  final String label;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8 * s, top: 6 * s, bottom: 6 * s),
          child: figmaText(
            label,
            size: 10 * s,
            weight: FontWeight.w600,
            letterSpacing: 0.5 * s,
            lineHeight: 12 * s,
            color: p.body,
          ),
        ),
        Container(
          width: 358 * s,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16 * s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2 * s,
                offset: Offset(0, 1 * s),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16 * s),
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }
}

/// One settings row: icon tile, title, optional subtitle, trailing value /
/// switch / chevron. Purely presentational.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.scale,
    required this.icon,
    required this.title,
    this.subtitle,
    this.height = 70,
    this.showDivider = true,
    this.iconColor,
    this.tileColor,
    this.value,
    this.valuePill,
    this.valuePillColor,
    this.valuePillTextColor,
    this.switchValue,
    this.onToggle,
    this.onTap,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String? subtitle;
  final double height;
  final bool showDivider;
  final Color? iconColor;
  final Color? tileColor;
  final String? value;
  final String? valuePill;
  final Color? valuePillColor;
  final Color? valuePillTextColor;
  final bool? switchValue;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    Widget trailing() {
      if (switchValue != null) {
        return Semantics(
          label: tr(title),
          toggled: switchValue,
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onToggle?.call(!switchValue!),
            child: Container(
              width: 48 * s,
              height: 28 * s,
              decoration: BoxDecoration(
                color: switchValue! ? p.ember : p.bone,
                borderRadius: BorderRadius.circular(999 * s),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 160),
                alignment: switchValue! ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(2 * s),
                  child: Container(
                    width: 24 * s, height: 24 * s,
                    decoration: BoxDecoration(
                      color: p.surface, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 2 * s, offset: Offset(0, 1 * s))],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      if (valuePill != null) {
        return Container(
          constraints: BoxConstraints(minWidth: 49 * s),
          padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
          decoration: BoxDecoration(color: valuePillColor, borderRadius: BorderRadius.circular(999 * s)),
          child: figmaText(valuePill!, size: 10 * s, weight: FontWeight.w600,
              letterSpacing: 0.4 * s, lineHeight: 12 * s, color: valuePillTextColor ?? p.sage),
        );
      }
      return Row(mainAxisSize: MainAxisSize.min, children: [
        if (value != null) ...[
          figmaText(value!, size: 12 * s, weight: FontWeight.w400,
              letterSpacing: 0.12 * s, lineHeight: 16 * s, color: p.body),
          SizedBox(width: 4 * s),
        ],
        Icon(Directionality.of(context) == TextDirection.rtl
            ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
            size: 14 * s, color: p.body.withValues(alpha: 0.60)),
      ]);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: BoxConstraints(minHeight: height * s),
        decoration: BoxDecoration(
          border: showDivider ? Border(top: BorderSide(color: p.container, width: 1 * s)) : null,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
        child: Row(
          children: [
            Container(
              width: 36 * s, height: 36 * s,
              decoration: BoxDecoration(color: tileColor ?? p.panel,
                  borderRadius: BorderRadius.circular(12 * s)),
              child: Icon(icon, size: 17 * s, color: iconColor ?? p.body),
            ),
            SizedBox(width: 16 * s),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                figmaText(title, size: 16 * s, weight: FontWeight.w600,
                    letterSpacing: -0.08 * s, lineHeight: 22 * s, color: p.ink),
                if (subtitle != null)
                  figmaText(subtitle!, size: 12 * s, weight: FontWeight.w400,
                      letterSpacing: 0.12 * s, lineHeight: 16 * s, color: p.body),
              ],
            )),
            SizedBox(width: 12 * s),
            trailing(),
          ],
        ),
      ),
    );
  }
}
