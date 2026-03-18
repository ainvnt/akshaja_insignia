import 'package:akshaja_insignia/src/presentation/models/society_home_models.dart';
import 'package:akshaja_insignia/src/presentation/society_notice_detail_screen.dart';
import 'package:flutter/material.dart';

class SocietyNoticesScreen extends StatelessWidget {
  const SocietyNoticesScreen({
    super.key,
    required this.notices,
  });

  final List<SocietyNoticeData> notices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F1E8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Society Notices',
          style: TextStyle(
            color: Color(0xFF312F2B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          const _NoticesHero(),
          const SizedBox(height: 18),
          _NoticesSummary(total: notices.length),
          const SizedBox(height: 18),
          for (var i = 0; i < notices.length; i++) ...[
            _NoticeListCard(
              data: notices[i],
              onTap: () => _openNotice(context, notices[i]),
            ),
            if (i < notices.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  void _openNotice(BuildContext context, SocietyNoticeData notice) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SocietyNoticeDetailScreen(notice: notice),
      ),
    );
  }
}

class _NoticesHero extends StatelessWidget {
  const _NoticesHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF262246), Color(0xFF4A4090), Color(0xFF7B6CCF)],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stay updated with every society announcement',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Important updates, events, maintenance windows, and community alerts are collected here.',
            style: TextStyle(
              color: Color(0xFFDAD9F2),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticesSummary extends StatelessWidget {
  const _NoticesSummary({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: '$total',
            subtitle: 'Available notices',
            color: const Color(0xFFFFF7D7),
            icon: Icons.campaign_outlined,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _SummaryCard(
            title: 'Live',
            subtitle: 'Community feed',
            color: Color(0xFFEAF2FF),
            icon: Icons.wifi_tethering_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF312F2B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF312F2B),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7E776F),
                    fontSize: 13,
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

class _NoticeListCard extends StatelessWidget {
  const _NoticeListCard({
    required this.data,
    required this.onTap,
  });

  final SocietyNoticeData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 92,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: Color(0xFF4067B3),
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Color(0xFFFF4862), size: 10),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data.title,
                            style: const TextStyle(
                              color: Color(0xFF312F2B),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data.timeLabel,
                          style: const TextStyle(
                            color: Color(0xFF7E776F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.body,
                      style: const TextStyle(
                        color: Color(0xFF6F6860),
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F2FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Read full notice',
                              style: TextStyle(
                                color: Color(0xFF5140A4),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Color(0xFF5140A4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
