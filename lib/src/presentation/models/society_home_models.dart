import 'package:flutter/material.dart';

class ShortcutTabData {
  const ShortcutTabData(this.label, this.icon);

  final String label;
  final IconData icon;
}

class CircleActionData {
  const CircleActionData(
    this.label,
    this.icon, {
    this.showAddBadge = false,
    this.square = false,
  });

  final String label;
  final IconData icon;
  final bool showAddBadge;
  final bool square;
}

class QuickActionData {
  const QuickActionData({
    required this.label,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final IconData icon;
  final bool highlight;
}

class PromoCardData {
  const PromoCardData({
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.secondary,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color primary;
  final Color secondary;
  final IconData icon;
}

class BottomNavData {
  const BottomNavData(this.label, this.icon);

  final String label;
  final IconData icon;
}

class SocietyNoticeData {
  const SocietyNoticeData({
    required this.title,
    required this.body,
    required this.timeLabel,
    this.fullBody,
  });

  final String title;
  final String body;
  final String timeLabel;
  final String? fullBody;
}
