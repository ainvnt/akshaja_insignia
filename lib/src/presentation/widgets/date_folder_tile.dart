import 'package:akshaja_insignia/src/presentation/models/date_folder_group.dart';
import 'package:flutter/material.dart';

class DateFolderTile extends StatelessWidget {
  const DateFolderTile({
    super.key,
    required this.folder,
    required this.onOpen,
    required this.onDeleteLocal,
    required this.onDeleteFolder,
  });

  final DateFolderGroup folder;
  final VoidCallback onOpen;
  final VoidCallback onDeleteLocal;
  final VoidCallback onDeleteFolder;

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
            PopupMenuButton<_FolderAction>(
              tooltip: 'Folder actions',
              onSelected: (value) {
                switch (value) {
                  case _FolderAction.deleteLocalCopies:
                    onDeleteLocal();
                  case _FolderAction.deleteFolderData:
                    onDeleteFolder();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<_FolderAction>(
                  value: _FolderAction.deleteLocalCopies,
                  child: Text('Delete local copies'),
                ),
                PopupMenuItem<_FolderAction>(
                  value: _FolderAction.deleteFolderData,
                  child: Text('Delete folder data'),
                ),
              ],
              icon: const Icon(Icons.more_vert_rounded),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}

enum _FolderAction { deleteLocalCopies, deleteFolderData }
