import 'package:do_save_money/core/auth/auth_controller.dart';
import 'package:do_save_money/feature/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  static String name = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController(text: 'visionwill3322@gmail.com');
  final _pwCtrl = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Obx(() {
        final isLoading = c.isLoading.value;
        final err = c.errorMessage.value;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: '이메일'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pwCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호'),
              ),
              const SizedBox(height: 12),

              if (err != null) ...[
                Text(err, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            await c.signIn(
                              email: _emailCtrl.text,
                              password: _pwCtrl.text,
                            );

                            // 성공 시 자동으로 authStateChanges로 user가 채워짐
                            if (c.user.value != null) {
                              Get.back(); // 이전 화면으로 돌아가기
                            }
                          },
                  child: isLoading ? const Text('로그인 중...') : const Text('로그인'),
                ),
              ),

              TextButton(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          final email = _emailCtrl.text.trim();
                          if (email.isEmpty) {
                            Get.snackbar('안내', '비밀번호 재설정 메일을 받을 이메일을 입력하세요.');
                            return;
                          }
                          await c.resetPassword(email: email);
                          if (c.errorMessage.value == null) {
                            Get.snackbar('완료', '비밀번호 재설정 메일을 보냈습니다.');
                          }
                        },
                child: const Text('비밀번호를 잊었나요? (재설정 메일)'),
              ),

              const Spacer(),

              TextButton(
                onPressed:
                    isLoading
                        ? null
                        : () {
                          Get.to(() => const SignUpPage());
                        },
                child: const Text('회원가입'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
