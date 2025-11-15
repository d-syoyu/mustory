import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_controller.dart';

class SignupPage extends HookConsumerWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final displayNameController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    // Navigate to home when authenticated
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (_, __, ___, ____) {
          context.go('/');
        },
      );
    });

    Future<void> handleSignup() async {
      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          displayNameController.text.isEmpty) {
        errorMessage.value = 'すべての項目を入力してください';
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        errorMessage.value = 'パスワードが一致しません';
        return;
      }

      if (passwordController.text.length < 6) {
        errorMessage.value = 'パスワードは6文字以上で入力してください';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      try {
        await ref.read(authControllerProvider.notifier).signUp(
              email: emailController.text.trim(),
              password: passwordController.text,
              displayName: displayNameController.text.trim(),
            );
      } catch (e) {
        errorMessage.value = 'サインアップに失敗しました: ${e.toString()}';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント作成'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              TextField(
                controller: displayNameController,
                decoration: const InputDecoration(
                  labelText: '表示名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: !isLoading.value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading.value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'パスワード（6文字以上）',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                enabled: !isLoading.value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'パスワード（確認）',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                enabled: !isLoading.value,
                onSubmitted: (_) => handleSignup(),
              ),
              if (errorMessage.value != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage.value!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading.value ? null : handleSignup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('アカウント作成', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: isLoading.value
                    ? null
                    : () {
                        context.pop();
                      },
                child: const Text('すでにアカウントをお持ちの方はこちら'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
