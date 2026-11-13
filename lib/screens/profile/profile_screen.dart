import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/app_bottom_nav.dart';
import 'package:daily_spark/design_system/widgets/app_top_bar.dart';
import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/screens/profile/widgets/profile_identity_card.dart';
import 'package:daily_spark/screens/profile/widgets/settings_group.dart';
import 'package:daily_spark/screens/profile/widgets/stat_tile.dart';

/// PURE UI — Profile ("Shahd's Journey").
/// No state container, no network: taps are reported to the parent.
/// Figma: node 126:16289 — 390 × 844 viewport, 1585 of content.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.onSettings,
    this.onShare,
    this.onEdit,
    this.onStatTap,
    this.onPersonalDetails,
    this.onCloudSync,
    this.onToggleReminders,
    this.onToggleSound,
    this.onAppearance,
    this.onLanguage,
    this.onGuide,
    this.onAbout,
    this.onLogOut,
    this.onNavTap,
    this.remindersOn = true,
    this.soundOn = true,
    this.themeDark = false,
  });

  final VoidCallback? onSettings;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;
  final ValueChanged<int>? onStatTap;
  final VoidCallback? onPersonalDetails;
  final VoidCallback? onCloudSync;
  final ValueChanged<bool>? onToggleReminders;
  final ValueChanged<bool>? onToggleSound;
  final VoidCallback? onAppearance;
  final VoidCallback? onLanguage;
  final VoidCallback? onGuide;
  final VoidCallback? onAbout;
  final VoidCallback? onLogOut;
  final ValueChanged<int>? onNavTap;
  final bool remindersOn;
  final bool soundOn;
  final bool themeDark;

  static Color get _brown => p.body;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    return Scaffold(
      backgroundColor: p.canvas,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: 64 * s, bottom: 152 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _subHeader(s),
                        SizedBox(height: 24 * s),
                        ProfileIdentityCard(scale: s),
                        SizedBox(height: 24 * s),
                        Row(
                          children: [
                            StatTile(
                              scale: s,
                              value: '12d',
                              label: 'Streak',
                              icon: Icons.local_fire_department_rounded,
                              iconColor: p.emberDeep,
                              overlayColor:
                                  p.emberDeep.withValues(alpha: 0.10),
                            ),
                            SizedBox(width: 8 * s),
                            StatTile(
                              scale: s,
                              value: '100',
                              label: 'Completed',
                              icon: Icons.check_circle_rounded,
                              iconColor: p.sage,
                              overlayColor:
                                  p.sage.withValues(alpha: 0.10),
                            ),
                            SizedBox(width: 8 * s),
                            StatTile(
                              scale: s,
                              value: '6',
                              label: 'Active Habits',
                              icon: Icons.format_list_bulleted_rounded,
                              iconColor: p.ochre,
                              overlayColor:
                                  p.gold.withValues(alpha: 0.30),
                            ),
                          ],
                        ),
                        SizedBox(height: 24 * s),
                        LevelCard(scale: s),
                        SizedBox(height: 24 * s),
                        SettingsGroup(
                          scale: s,
                          label: 'ACCOUNT & SYNC',
                          rows: [
                            SettingsRow(
                              scale: s,
                              icon: Icons.person_outline_rounded,
                              title: 'Personal Details',
                              subtitle: 'Name, email, and ritual motto',
                              height: 70,
                              showDivider: false,
                              onTap: onPersonalDetails,
                            ),
                            SettingsRow(
                              scale: s,
                              icon: Icons.cloud_outlined,
                              iconColor: p.sage,
                              title: 'Spark Cloud Sync',
                              subtitle: 'Synced just now · 100% safe',
                              height: 71,
                              valuePill: 'Active',
                              valuePillColor:
                                  p.sage.withValues(alpha: 0.10),
                              onTap: onCloudSync,
                            ),
                          ],
                        ),
                        SizedBox(height: 16 * s),
                        SettingsGroup(
                          scale: s,
                          label: 'PREFERENCES',
                          rows: [
                            SettingsRow(
                              scale: s,
                              icon: Icons.alarm_rounded,
                              title: 'Daily Reminders',
                              subtitle: 'Morning & evening gentle cues',
                              height: 70,
                              showDivider: false,
                              switchValue: remindersOn,
                              onToggle: onToggleReminders,
                            ),
                            SettingsRow(
                              scale: s,
                              icon: Icons.vibration_rounded,
                              title: 'Sound & Haptic Spark',
                              subtitle: 'Tactile celebration on completion',
                              height: 71,
                              switchValue: soundOn,
                              onToggle: onToggleSound,
                            ),
                            SettingsRow(
                              scale: s,
                              icon: themeDark
                                  ? Icons.nightlight_round
                                  : Icons.wb_sunny_outlined,
                              title: 'Appearance & Theme',
                              height: 69,
                              value: themeDark ? 'Midnight' : 'Warm Light',
                              onTap: onAppearance,
                            ),
                            SettingsRow(
                              scale: s,
                              icon: Icons.translate_rounded,
                              title: 'Language',
                              height: 69,
                              value: 'English',
                              onTap: onLanguage,
                            ),
                          ],
                        ),
                        SizedBox(height: 16 * s),
                        SettingsGroup(
                          scale: s,
                          label: 'SUPPORT & COMMUNITY',
                          rows: [
                            SettingsRow(
                              scale: s,
                              icon: Icons.menu_book_outlined,
                              title: 'Ritual Guide & Insights',
                              height: 68,
                              showDivider: false,
                              onTap: onGuide,
                            ),
                            SettingsRow(
                              scale: s,
                              icon: Icons.info_outline_rounded,
                              iconColor: p.emberDeep,
                              title: 'About Daily Spark',
                              height: 69,
                              value: 'v2.4.0',
                              onTap: onAbout,
                            ),
                          ],
                        ),
                        SizedBox(height: 24 * s),
                        _signOutBlock(s),
                        SizedBox(height: 24 * s),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppTopBar(
              scale: s,
              title: 'Profile',
              showSettings: true,
              onSettings: onSettings,
            ),
          ),
          Positioned(
            left: 16 * s,
            right: 16 * s,
            bottom: 20 * s,
            child: AppBottomNav(
              scale: s,
              selectedIndex: 3,
              selectedWidth: 84.3,
              frosted: true,
              icons: const [
                Icons.local_fire_department_rounded,
                Icons.checklist_rounded,
                Icons.insights_rounded,
                Icons.person_rounded,
              ],
              onTap: onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _subHeader(double s) {
    return SizedBox(
      height: 48 * s,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 8 * s,
            child: figmaText(
              'PERSONAL SPACE',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: _brown,
            ),
          ),
          Positioned(
            left: 0,
            top: 20 * s,
            child: figmaText(
              "Shahd's Journey",
              size: 18 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.45 * s,
              lineHeight: 24 * s,
              color: p.ink,
            ),
          ),
          Positioned(
            left: 266 * s,
            top: 4 * s,
            child: _circleButton(s, Icons.ios_share_rounded, onShare),
          ),
          Positioned(
            left: 314 * s,
            top: 4 * s,
            child: _circleButton(s, Icons.edit_outlined, onEdit),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(double s, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44 * s,
        height: 44 * s,
        decoration: BoxDecoration(
          color: p.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2 * s,
              offset: Offset(0, 1 * s),
            ),
          ],
        ),
        child: Icon(icon, size: 18 * s, color: _brown),
      ),
    );
  }

  Widget _signOutBlock(double s) {
    return SizedBox(
      width: 358 * s,
      child: Column(
        children: [
          SizedBox(height: 8 * s),
          GestureDetector(
            onTap: onLogOut,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 358 * s,
              height: 48 * s,
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(12 * s),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2 * s,
                    offset: Offset(0, 1 * s),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 14 * s, color: _brown),
                  SizedBox(width: 5 * s),
                  figmaText(
                    'Log Out of Daily Spark',
                    size: 14 * s,
                    weight: FontWeight.w600,
                    letterSpacing: 0.14 * s,
                    lineHeight: 18 * s,
                    color: _brown,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16 * s),
          figmaText(
            'Daily Spark v2.4.0 · Crafted with care',
            size: 10 * s,
            weight: FontWeight.w600,
            letterSpacing: 0.25 * s,
            lineHeight: 12 * s,
            color: _brown.withValues(alpha: 0.70),
          ),
          SizedBox(height: 4 * s),
          figmaText(
            'Architecture of personal habits & calm focus',
            size: 10 * s,
            weight: FontWeight.w600,
            letterSpacing: 0.4 * s,
            lineHeight: 12 * s,
            color: _brown.withValues(alpha: 0.50),
          ),
        ],
      ),
    );
  }
}
