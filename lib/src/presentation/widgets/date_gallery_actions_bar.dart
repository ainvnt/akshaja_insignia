import 'package:flutter/material.dart';

class DateGalleryActionsBar extends StatelessWidget {
  const DateGalleryActionsBar({
    super.key,
    required this.selectionMode,
    required this.selectedCount,
    required this.onDeleteAllLocal,
  });

  final bool selectionMode;
  final int selectedCount;
  final VoidCallback onDeleteAllLocal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onDeleteAllLocal,
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Delete All Local'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              selectionMode
                  ? '$selectedCount selected'
                  : 'Long-press images to select',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
