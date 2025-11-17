import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../application/upload_controller.dart';

class TrackUploadPage extends HookConsumerWidget {
  const TrackUploadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadControllerProvider);
    final titleController = useTextEditingController();
    final artistController = useTextEditingController();
    final audioFile = useState<File?>(null);
    final artworkFile = useState<File?>(null);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Track'),
      ),
      body: uploadState.when(
        idle: () => _buildUploadForm(
          context: context,
          ref: ref,
          formKey: formKey,
          titleController: titleController,
          artistController: artistController,
          audioFile: audioFile,
          artworkFile: artworkFile,
        ),
        picking: () => const Center(
          child: CircularProgressIndicator(),
        ),
        initializing: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Preparing upload...'),
            ],
          ),
        ),
        uploading: (progress, message) => _buildUploadingView(
          progress: progress,
          message: message,
        ),
        processing: (trackId, progress) => _buildProcessingView(
          trackId: trackId,
          progress: progress,
        ),
        completed: (trackId) => _buildCompletedView(
          context: context,
          trackId: trackId,
        ),
        error: (message) => _buildErrorView(
          context: context,
          ref: ref,
          message: message,
          titleController: titleController,
          artistController: artistController,
          audioFile: audioFile,
          artworkFile: artworkFile,
        ),
      ),
    );
  }

  Widget _buildUploadForm({
    required BuildContext context,
    required WidgetRef ref,
    required GlobalKey<FormState> formKey,
    required TextEditingController titleController,
    required TextEditingController artistController,
    required ValueNotifier<File?> audioFile,
    required ValueNotifier<File?> artworkFile,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Audio File Picker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio File',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (audioFile.value == null)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.audio,
                          );
                          if (result != null && result.files.single.path != null) {
                            audioFile.value = File(result.files.single.path!);
                          }
                        },
                        icon: const Icon(Icons.audio_file),
                        label: const Text('Select Audio File'),
                      )
                    else
                      ListTile(
                        leading: const Icon(Icons.music_note, color: Colors.blue),
                        title: Text(audioFile.value!.path.split('/').last),
                        subtitle: Text(
                          '${(audioFile.value!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => audioFile.value = null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Artwork Picker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Artwork (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (artworkFile.value == null)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            artworkFile.value = File(image.path);
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('Select Artwork'),
                      )
                    else
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              artworkFile.value!,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => artworkFile.value = null,
                            icon: const Icon(Icons.close),
                            label: const Text('Remove'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metadata Form
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Track Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: artistController,
              decoration: const InputDecoration(
                labelText: 'Artist Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an artist name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Upload Button
            ElevatedButton(
              onPressed: audioFile.value == null
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        await ref.read(uploadControllerProvider.notifier).uploadTrack(
                              title: titleController.text.trim(),
                              artistName: artistController.text.trim(),
                              audioFile: audioFile.value!,
                              artworkFile: artworkFile.value,
                            );
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Upload Track'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadingView({
    required double progress,
    String? message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: progress),
            const SizedBox(height: 24),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView({
    required String trackId,
    int? progress,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Processing track...',
              style: TextStyle(fontSize: 18),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              Text('$progress%'),
            ],
            const SizedBox(height: 16),
            const Text(
              'This may take a few minutes',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedView({
    required BuildContext context,
    required String trackId,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your track has been uploaded and is ready to play.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.go('/');
              },
              child: const Text('Go to Home'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.go('/tracks/$trackId');
              },
              child: const Text('View Track'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView({
    required BuildContext context,
    required WidgetRef ref,
    required String message,
    required TextEditingController titleController,
    required TextEditingController artistController,
    required ValueNotifier<File?> audioFile,
    required ValueNotifier<File?> artworkFile,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload Failed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (audioFile.value != null) {
                  await ref.read(uploadControllerProvider.notifier).retry(
                        title: titleController.text.trim(),
                        artistName: artistController.text.trim(),
                        audioFile: audioFile.value!,
                        artworkFile: artworkFile.value,
                      );
                }
              },
              child: const Text('Retry Upload'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.read(uploadControllerProvider.notifier).reset();
              },
              child: const Text('Start Over'),
            ),
          ],
        ),
      ),
    );
  }
}
