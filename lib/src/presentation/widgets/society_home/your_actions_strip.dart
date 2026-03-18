import 'package:akshaja_insignia/src/presentation/models/society_home_models.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/society_home_palette.dart';
import 'package:flutter/material.dart';

class SocietyHomeYourActionsStrip extends StatelessWidget {
  const SocietyHomeYourActionsStrip({super.key, required this.actions});

  final List<QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _QuickActionCard(data: actions[index]);
        },
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data});

  final QuickActionData data;

  @override
  Widget build(BuildContext context) {
    final highlight = data.highlight;

    return SizedBox(
      width: highlight ? 200 : 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: highlight
                  ? const LinearGradient(
                      colors: [Color(0xFF5CBDF2), Color(0xFF1E5FA8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFFFEFD), Color(0xFFF5F1EC)],
                    ),
              boxShadow: highlight
                  ? [
                      BoxShadow(
                        color: const Color(0xFF5CBDF2).withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                data.icon,
                size: highlight ? 44 : 36,
                color: highlight ? Colors.white : const Color(0xFF8A7E65),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF3A3834),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
