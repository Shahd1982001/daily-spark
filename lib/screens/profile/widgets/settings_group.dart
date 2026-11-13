import 'package:flutter/material.dart';

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
            color: const Color(0xFF57423B),
          ),
        ),
        Container(
          width: 358 * s,
          decoration: BoxDecoration(
            color: Colors.white,
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
    this.iconColor = const Color(0xFF57423B),
    this.tileColor = const Color(0xFFF3F4F0),
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
  final Color iconColor;
  final Color tileColor;
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 358 * s,
        height: height * s,
        decoration: BoxDecoration(
          border: showDivider
              ? Border(top: BorderSide(color: const Color(0xFFEDEEEB), width: 1 * s))
              : null,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16 * s,
              top: (height - 36) / 2 * s,
              child: Container(
                width: 36 * s,
                height: 36 * s,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(12 * s),
                ),
                child: Icon(icon, size: 17 * s, color: iconColor),
              ),
            ),
            Positioned(
              left: 68 * s,
              top: (subtitle == null ? height / 2 - 11 : 16) * s,
              child: figmaText(
                title,
                size: 16 * s,
                weight: FontWeight.w600,
                letterSpacing: -0.08 * s,
                lineHeight: 22 * s,
                color: const Color(0xFF191C1A),
              ),
            ),
            if (subtitle != null)
              Positioned(
                left: 68 * s,
                top: 38 * s,
                child: figmaText(
                  subtitle!,
                  size: 12 * s,
                  weight: FontWeight.w400,
                  letterSpacing: 0.12 * s,
                  lineHeight: 16 * s,
                  color: const Color(0xFF57423B),
                ),
              ),
            if (switchValue != null)
              Positioned(
                right: 16 * s,
                top: (height - 28) / 2 * s,
                child: GestureDetector(
                  onTap: () => onToggle?.call(!switchValue!),
                  child: Container(
                    width: 48 * s,
                    height: 28 * s,
                    decoration: BoxDecoration(
                      color: switchValue!
                          ? const Color(0xFFFF6B2C)
                          : const Color(0xFFDCDEDA),
                      borderRadius: BorderRadius.circular(999 * s),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 160),
                      alignment: switchValue!
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(2 * s),
                        child: Container(
                          width: 24 * s,
                          height: 24 * s,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 2 * s,
                                offset: Offset(0, 1 * s),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (valuePill != null)
              Positioned(
                right: 16 * s,
                top: (height - 16) / 2 * s,
                child: Container(
                  width: 49 * s,
                  height: 16 * s,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: valuePillColor,
                    borderRadius: BorderRadius.circular(999 * s),
                  ),
                  child: figmaText(
                    valuePill!,
                    size: 10 * s,
                    weight: FontWeight.w600,
                    letterSpacing: 0.4 * s,
                    lineHeight: 12 * s,
                    color: valuePillTextColor ?? const Color(0xFF3A6750),
                  ),
                ),
              ),
            if (value != null && valuePill == null)
              Positioned(
                right: 30 * s,
                top: (height - 16) / 2 * s,
                child: figmaText(
                  value!,
                  size: 12 * s,
                  weight: FontWeight.w400,
                  letterSpacing: 0.12 * s,
                  lineHeight: 16 * s,
                  color: const Color(0xFF57423B),
                ),
              ),
            if (switchValue == null && valuePill == null)
              Positioned(
                right: 14 * s,
                top: (height - 10) / 2 * s,
                child: Icon(Icons.chevron_right_rounded,
                    size: 14 * s,
                    color: const Color(0xFF57423B).withValues(alpha: 0.60)),
              ),
          ],
        ),
      ),
    );
  }
}
