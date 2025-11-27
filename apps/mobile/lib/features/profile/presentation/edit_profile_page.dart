import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_controller.dart';
import '../application/profile_controller.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends HookConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.maybeWhen(
      authenticated: (userId, email, displayName, _) {
        final profileState = ref.watch(profileControllerProvider(userId));
        final profileNotifier =
            ref.read(profileControllerProvider(userId).notifier);
        final profileRepository = ref.read(profileRepositoryProvider);
        final profile = profileState.profile;

        final displayNameController =
            useTextEditingController(text: profile?.displayName ?? displayName);
        final usernameController =
            useTextEditingController(text: profile?.username ?? '');
        final bioController =
            useTextEditingController(text: profile?.bio ?? '');
        final locationController =
            useTextEditingController(text: profile?.location ?? '');
        final linkController =
            useTextEditingController(text: profile?.linkUrl ?? '');
        final avatarController =
            useTextEditingController(text: profile?.avatarUrl ?? '');
        final isUploadingAvatar = useState(false);

        useEffect(() {
          if (profile != null) {
            displayNameController.text = profile.displayName;
            usernameController.text = profile.username;
            bioController.text = profile.bio ?? '';
            locationController.text = profile.location ?? '';
            linkController.text = profile.linkUrl ?? '';
            avatarController.text = profile.avatarUrl ?? '';
          }
          return null;
        }, [profile]);

        return Scaffold(
          appBar: AppBar(
            title: const Text('プロフィール編集'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
                TextFormField(
                  controller: displayNameController,
                  decoration: const InputDecoration(
                    labelText: '表示名',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'ユーザー名 (英数字とアンダースコア、3-30文字)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bioController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: '自己紹介',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: '場所',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: 'リンク',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: avatarController,
                  decoration: const InputDecoration(
                    labelText: 'アバターURL',
                    helperText: '「画像をアップロード」で生成したURLを自動入力できます',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isUploadingAvatar.value
                      ? null
                      : () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                              source: ImageSource.gallery, maxWidth: 2048);
                          if (picked == null) return;
                          isUploadingAvatar.value = true;
                          try {
                            final publicUrl =
                                await profileRepository.uploadAvatar(picked);
                            avatarController.text = publicUrl;
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('アバターをアップロードしました')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('アバターアップロードに失敗しました: $e')),
                              );
                            }
                          } finally {
                            isUploadingAvatar.value = false;
                          }
                        },
                  icon: isUploadingAvatar.value
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload),
                  label: const Text('画像をアップロード'),
                ),
                const SizedBox(height: 24),
                profileState.isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: () async {
                          await profileNotifier.updateProfile(
                            displayName: displayNameController.text.trim(),
                            username: usernameController.text.trim(),
                            bio: bioController.text.trim(),
                            location: locationController.text.trim(),
                            linkUrl: linkController.text.trim(),
                            avatarUrl: avatarController.text.trim(),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('プロフィールを更新しました')),
                            );
                            context.pop();
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('保存する'),
                      ),
                if (profileState.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    profileState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
        );
      },
      orElse: () => const Scaffold(
        body: Center(child: Text('ログインしてください')),
      ),
    );
  }
}
