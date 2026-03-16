import 'package:akshaja_insignia/src/presentation/widgets/society_home/society_home_palette.dart';
import 'package:flutter/material.dart';

class SocietyHomeTopHeader extends StatelessWidget {
  const SocietyHomeTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFFC5C1B8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Flexible(
                      child: Text(
                        '...206',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: SocietyHomePalette.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: SocietyHomePalette.primaryText,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: _LocationPill()),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.search_rounded,
          size: 36,
          color: SocietyHomePalette.primaryText,
        ),
        const SizedBox(width: 8),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD63A), Color(0xFFFF8D14)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFFFA600),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFF1DFA7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.apartment_rounded,
            size: 16,
            color: SocietyHomePalette.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE6E0D5)),
      ),
      child: const Row(
        children: [
          _LocationBadge(),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'fting Hor',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF726A60),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFFB5AE9F),
          ),
        ],
      ),
    );
  }
}

class _LocationBadge extends StatelessWidget {
  const _LocationBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xFFE7F0FF),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.location_on_rounded,
        size: 22,
        color: Color(0xFF1B6FE5),
      ),
    );
  }
}
