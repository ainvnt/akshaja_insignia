import 'package:akshaja_insignia/src/presentation/widgets/society_home/society_home_palette.dart';
import 'package:flutter/material.dart';

class SocietyHomeMiniSuggestionRow extends StatelessWidget {
  const SocietyHomeMiniSuggestionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _MiniSuggestionCard(
            icon: Icons.local_shipping_outlined,
            title: 'Parcel Room',
            color: Color(0xFFF8E7E9),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MiniSuggestionCard(
            icon: Icons.celebration_outlined,
            title: 'Club Events',
            color: Color(0xFFE8F5EF),
          ),
        ),
      ],
    );
  }
}

class _MiniSuggestionCard extends StatelessWidget {
  const _MiniSuggestionCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF555046)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: SocietyHomePalette.primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
