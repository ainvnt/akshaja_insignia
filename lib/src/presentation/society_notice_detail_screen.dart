import 'package:akshaja_insignia/src/presentation/models/society_home_models.dart';
import 'package:flutter/material.dart';

class SocietyNoticeDetailScreen extends StatelessWidget {
  const SocietyNoticeDetailScreen({
    super.key,
    required this.notice,
  });

  final SocietyNoticeData notice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F1E8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notice Details',
          style: TextStyle(
            color: Color(0xFF312F2B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B2454), Color(0xFF5344A4), Color(0xFF7D6DD1)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFFFF6276), size: 12),
                    const SizedBox(width: 10),
                    Text(
                      notice.timeLabel,
                      style: const TextStyle(
                        color: Color(0xFFE4E2FA),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  notice.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Community announcement',
                  style: TextStyle(
                    color: Color(0xFFD6D3F2),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              notice.fullBody ?? notice.body,
              style: const TextStyle(
                color: Color(0xFF514B43),
                fontSize: 16,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
