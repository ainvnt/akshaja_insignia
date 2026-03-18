import 'package:akshaja_insignia/src/presentation/models/society_home_models.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/society_home_palette.dart';
import 'package:flutter/material.dart';

class SocietyHomeVisitorsPanel extends StatelessWidget {
  const SocietyHomeVisitorsPanel({super.key, required this.actions});

  final List<CircleActionData> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: actions
                .map((action) => _SimpleActionButton(data: action))
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.home_repair_service_rounded,
                color: const Color(0xFFD1801F),
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Book daily services in minutes',
                  style: const TextStyle(
                    color: Color(0xFF3A3834),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8A7E65),
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SimpleActionButton extends StatelessWidget {
  const _SimpleActionButton({required this.data});

  final CircleActionData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1EC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(data.icon, size: 24, color: const Color(0xFF8A7E65)),
        ),
        const SizedBox(height: 8),
        Text(
          data.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF3A3834),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
