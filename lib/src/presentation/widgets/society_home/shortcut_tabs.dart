import 'package:akshaja_insignia/src/presentation/models/society_home_models.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/society_home_palette.dart';
import 'package:flutter/material.dart';

class SocietyHomeShortcutTabs extends StatelessWidget {
  const SocietyHomeShortcutTabs({
    super.key,
    required this.tabs,
  });

  final List<ShortcutTabData> tabs;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tabs.length; i++) ...[
          Expanded(child: _ShortcutTab(data: tabs[i])),
          if (i < tabs.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _ShortcutTab extends StatelessWidget {
  const _ShortcutTab({required this.data});

  final ShortcutTabData data;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: data.selected
                ? const LinearGradient(
                    colors: [Color(0xFFFFEAA7), Color(0xFFFFB85A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: data.selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            data.icon,
            size: 30,
            color: data.selected
                ? const Color(0xFFC95D0E)
                : const Color(0xFF8E8578),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: SocietyHomePalette.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    if (!data.selected) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: content,
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: content,
    );
  }
}
