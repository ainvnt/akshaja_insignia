import 'package:akshaja_insignia/src/presentation/models/date_folder_group.dart';
import 'package:flutter/material.dart';

class DateFolderTile extends StatelessWidget {
  const DateFolderTile({
    super.key,
    required this.folder,
    required this.onOpen,
    required this.onDeleteLocal,
  });

  final DateFolderGroup folder;
  final VoidCallback onOpen;
  final VoidCallback onDeleteLocal;

  @override
  Widget build(BuildContext context) {
    final folderLabel = folder.key.replaceAll('/', '-');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: const Icon(Icons.folder_rounded, color: Colors.amber),
        title: Text(
          folderLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${folder.photos.length} image(s)'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Delete local files in folder',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: onDeleteLocal,
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}
