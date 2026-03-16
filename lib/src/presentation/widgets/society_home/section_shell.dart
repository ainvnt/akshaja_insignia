import 'package:flutter/material.dart';

class SocietyHomeSectionShell extends StatelessWidget {
  const SocietyHomeSectionShell({
    super.key,
    required this.title,
    required this.trailing,
    required this.child,
    this.backgroundColor = Colors.white,
    this.titleSuffix,
  });

  final String title;
  final String trailing;
  final Widget child;
  final Widget? titleSuffix;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: backgroundColor == Colors.white
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF4B483F),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (titleSuffix != null) ...[
                const SizedBox(width: 8),
                titleSuffix!,
              ],
              const Spacer(),
              Text(
                trailing,
                style: const TextStyle(
                  color: Color(0xFF807A70),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class SocietyHomeEditBadge extends StatelessWidget {
  const SocietyHomeEditBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFFE5FBF7),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.edit_outlined,
        size: 16,
        color: Color(0xFF469A89),
      ),
    );
  }
}
