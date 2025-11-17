import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../domain/track.dart';

class TrackEditDialog extends HookConsumerWidget {
  final Track track;
  final Future<void> Function(String title, String artistName, String? storyLead, String? storyBody) onSave;
  final Future<void> Function()? onDelete;

  const TrackEditDialog({
    super.key,
    required this.track,
    required this.onSave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(text: track.title);
    final artistController = useTextEditingController(text: track.artistName);
    final storyLeadController = useTextEditingController(text: track.story?['lead'] as String? ?? '');
    final storyBodyController = useTextEditingController(text: track.story?['body'] as String? ?? '');
    final isSaving = useState(false);
    final isDeleting = useState(false);

    return AlertDialog(
      title: const Text('トラック・ストーリーを編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'トラック情報',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
              ),
              enabled: !isSaving.value && !isDeleting.value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: artistController,
              decoration: const InputDecoration(
                labelText: 'アーティスト名',
                border: OutlineInputBorder(),
              ),
              enabled: !isSaving.value && !isDeleting.value,
            ),
            const SizedBox(height: 24),
            const Text(
              'ストーリー (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: storyLeadController,
              decoration: const InputDecoration(
                labelText: 'リード文',
                hintText: 'この曲についての短い紹介文',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              enabled: !isSaving.value && !isDeleting.value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: storyBodyController,
              decoration: const InputDecoration(
                labelText: '本文',
                hintText: 'この曲に込めた想いやストーリーを詳しく書いてください',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              minLines: 5,
              enabled: !isSaving.value && !isDeleting.value,
            ),
          ],
        ),
      ),
      actions: [
        if (onDelete != null)
          TextButton(
            onPressed: (isSaving.value || isDeleting.value)
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('確認'),
                        content: const Text('このトラックを削除しますか?\nこの操作は取り消せません。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('キャンセル'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('削除'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      isDeleting.value = true;
                      try {
                        await onDelete!();
                        if (context.mounted) {
                          Navigator.of(context).pop('deleted');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('トラックを削除しました'),
                            ),
                          );
                        }
                      } catch (e) {
                        isDeleting.value = false;
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('削除エラー: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: isDeleting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('削除'),
          ),
        TextButton(
          onPressed: (isSaving.value || isDeleting.value) ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: (isSaving.value || isDeleting.value)
              ? null
              : () async {
                  final title = titleController.text.trim();
                  final artistName = artistController.text.trim();
                  final storyLead = storyLeadController.text.trim();
                  final storyBody = storyBodyController.text.trim();

                  if (title.isEmpty || artistName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('タイトルとアーティスト名を入力してください'),
                      ),
                    );
                    return;
                  }

                  isSaving.value = true;
                  try {
                    await onSave(
                      title,
                      artistName,
                      storyLead.isNotEmpty ? storyLead : null,
                      storyBody.isNotEmpty ? storyBody : null,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('トラック・ストーリーを更新しました'),
                        ),
                      );
                    }
                  } catch (e) {
                    isSaving.value = false;
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('エラーが発生しました: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
          child: isSaving.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('保存'),
        ),
      ],
    );
  }
}
