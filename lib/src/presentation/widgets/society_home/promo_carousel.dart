import 'package:akshaja_insignia/src/presentation/models/society_home_models.dart';
import 'package:flutter/material.dart';

class SocietyHomePromoCarousel extends StatelessWidget {
  const SocietyHomePromoCarousel({
    super.key,
    required this.promos,
  });

  final List<PromoCardData> promos;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: promos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _PromoCard(data: promos[index]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _CarouselDot(active: true, wide: true),
            _CarouselDot(active: false),
            _CarouselDot(active: false),
            _CarouselDot(active: false),
            _CarouselDot(active: false),
          ],
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.data});

  final PromoCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [data.primary, data.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Icon(data.icon, size: 42, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Know More',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselDot extends StatelessWidget {
  const _CarouselDot({
    required this.active,
    this.wide = false,
  });

  final bool active;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? 34 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF8A7E65) : const Color(0xFFD9D1C6),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
