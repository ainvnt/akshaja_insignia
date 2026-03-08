import 'package:flutter/material.dart';

class HomeSummaryCard extends StatelessWidget {
  const HomeSummaryCard({
    super.key,
    required this.totalPhotos,
    required this.uploadedPhotos,
    this.pendingPhotos,
    this.uploadedLabel = 'Uploaded',
  });

  final int totalPhotos;
  final int uploadedPhotos;
  final int? pendingPhotos;
  final String uploadedLabel;

  @override
  Widget build(BuildContext context) {
    final pending = pendingPhotos ?? (totalPhotos - uploadedPhotos);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.16),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture Overview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Total',
                    value: '$totalPhotos',
                    icon: Icons.photo_library_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryItem(
                    label: uploadedLabel,
                    value: '$uploadedPhotos',
                    icon: Icons.cloud_done_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryItem(
                    label: 'Pending',
                    value: '$pending',
                    icon: Icons.schedule_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
