import 'package:akshaja_insignia/src/presentation/widgets/society_home/society_home_palette.dart';
import 'package:flutter/material.dart';

class SocietyHomeNoticeStrip extends StatelessWidget {
  const SocietyHomeNoticeStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 174,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _NoticeCard(
            title: 'Rule the Roads',
            subtitle: 'Live the Awesome Beat - the true king of SUVs.',
            timeLabel: '1d ago',
            dotColor: Color(0xFFFF445A),
            accent: Color(0xFFE9F2FF),
          ),
          SizedBox(width: 14),
          _SidePosterCard(),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.dotColor,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final Color dotColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 520,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 188,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [accent, const Color(0xFF9AB7FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 64,
                color: Color(0xFF375A9E),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SocietyHomePalette.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        color: Color(0xFFAAA39A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF676057),
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidePosterCard extends StatelessWidget {
  const _SidePosterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF7D6CF2), Color(0xFFB3A1FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: Text(
            'ADMISSIONS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
