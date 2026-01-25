import 'package:do_save_money/core/auth/auth_controller.dart';
import 'package:do_save_money/feature/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('가게부'),
        actions: [
          Obx(() {
            final u = auth.user.value;
            if (u == null) {
              return IconButton(
                icon: const Icon(Icons.login),
                onPressed: () => Get.to(() => const LoginPage()),
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await auth.signOut();
                  if (auth.errorMessage.value == null) {
                    Get.snackbar('완료', '로그아웃 했습니다.');
                  }
                },
              );
            }
          }),
        ],
      ),
      body: Center(
        child: Obx(() {
          final u = auth.user.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(u == null ? '현재: 비로그인(솔로 사용 가능)' : '현재 로그인: ${u.email}'),
              const SizedBox(height: 12),

              // 이메일 인증 상태 표시(선택)
              if (u != null) ...[
                Text(u.emailVerified ? '이메일 인증됨' : '이메일 미인증'),
                const SizedBox(height: 8),
                if (!u.emailVerified)
                  ElevatedButton(
                    onPressed:
                        auth.isLoading.value
                            ? null
                            : () async {
                              await auth.resendEmailVerification();
                              if (auth.errorMessage.value == null) {
                                Get.snackbar('완료', '인증 메일을 보냈습니다.');
                              }
                            },
                    child: const Text('인증 메일 다시 보내기'),
                  ),
                TextButton(
                  onPressed:
                      auth.isLoading.value
                          ? null
                          : () async {
                            await auth.refreshUser();
                          },
                  child: const Text('인증 상태 새로고침'),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}
