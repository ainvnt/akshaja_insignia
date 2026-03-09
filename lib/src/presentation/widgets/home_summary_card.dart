import 'package:flutter/material.dart';

class HomeSummaryCard extends StatelessWidget {
  const HomeSummaryCard({
    super.key,
    required this.totalPhotos,
    required this.uploadedPhotos,
    this.pendingPhotos,
    this.uploadedLabel = 'Uploaded',
    this.infoText,
    this.rangePhotos,
  });

  final int totalPhotos;
  final int uploadedPhotos;
  final int? pendingPhotos;
  final String uploadedLabel;
  final String? infoText;
  final int? rangePhotos;

  @override
  Widget build(BuildContext context) {
    final pending = pendingPhotos ?? (totalPhotos - uploadedPhotos);
    final metrics = <({String label, String value, IconData icon})>[
      (
        label: 'Total',
        value: '$totalPhotos',
        icon: Icons.photo_library_rounded,
      ),
      (
        label: uploadedLabel,
        value: '$uploadedPhotos',
        icon: Icons.cloud_done_rounded,
      ),
      (label: 'Pending', value: '$pending', icon: Icons.schedule_rounded),
      if (rangePhotos != null)
        (
          label: 'In Range',
          value: '$rangePhotos',
          icon: Icons.filter_alt_rounded,
        ),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.16),
            ],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (infoText != null) ...[
              Text(
                infoText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                final itemCount = metrics.length;
                final availableWidth =
                    constraints.maxWidth -
                    (spacing * (itemCount > 0 ? itemCount - 1 : 0));
                final itemWidth = itemCount > 0
                    ? availableWidth / itemCount
                    : constraints.maxWidth;

                return Row(
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      if (i > 0) const SizedBox(width: spacing),
                      SizedBox(
                        width: itemWidth,
                        child: _SummaryItem(
                          label: metrics[i].label,
                          value: metrics[i].value,
                          icon: metrics[i].icon,
                        ),
                      ),
                    ],
                  ],
                );
              },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            maxLines: 1,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
