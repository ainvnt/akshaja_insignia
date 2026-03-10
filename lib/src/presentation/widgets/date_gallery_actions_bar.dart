import 'package:flutter/material.dart';

class DateGalleryActionsBar extends StatelessWidget {
  const DateGalleryActionsBar({
    super.key,
    required this.selectionMode,
    required this.selectedCount,
  });

  final bool selectionMode;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectionMode ? '$selectedCount selected' : '',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
