import 'package:akshaja_insignia/src/presentation/models/society_home_models.dart';
import 'package:akshaja_insignia/src/presentation/widgets/society_home/society_home_palette.dart';
import 'package:flutter/material.dart';

class SocietyHomeYourActionsStrip extends StatelessWidget {
  const SocietyHomeYourActionsStrip({
    super.key,
    required this.actions,
  });

  final List<QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 154,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 30),
            itemCount: actions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return _QuickActionCard(data: actions[index]);
            },
          ),
        ),
        Positioned(
          top: 8,
          right: -18,
          bottom: 8,
          child: Container(
            width: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE91E34),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: const RotatedBox(
              quarterTurns: 3,
              child: Center(
                child: Text(
                  'Party Shuru!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
              borderRadius: BorderRadius.circular(22),
              gradient: highlight
                  ? const LinearGradient(
                      colors: [Color(0xFF56C7F2), Color(0xFF274E8D)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFFFEFD), Color(0xFFF4F1EC)],
                    ),
              border: highlight
                  ? null
                  : Border.all(color: const Color(0xFFF0EBE4)),
            ),
            child: Stack(
              children: [
                if (highlight)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF164D79),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(22),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Icon(
                    data.icon,
                    size: highlight ? 48 : 38,
                    color: highlight
                        ? Colors.white
                        : const Color(0xFF6A6760),
                  ),
                ),
                if (highlight)
                  const Positioned(
                    right: 18,
                    top: 18,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SocietyHomePalette.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
