import 'package:do_save_money/core/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailCtrl = TextEditingController(text: 'visionwill3322@gmail.com');
  final _pwCtrl = TextEditingController(text: '123456');
  final _pw2Ctrl = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
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
              TextField(
                controller: _pw2Ctrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호 확인'),
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
                            if (_pwCtrl.text != _pw2Ctrl.text) {
                              Get.snackbar('오류', '비밀번호가 일치하지 않습니다.');
                              return;
                            }

                            await c.signUp(
                              email: _emailCtrl.text,
                              password: _pwCtrl.text,
                            );

                            // 가입 성공 시 뒤로
                            if (c.user.value != null) {
                              Get.back();
                              Get.snackbar('완료', '회원가입 완료! 이메일 인증 메일을 보냈습니다.');
                            }
                          },
                  child: isLoading ? const Text('가입 중...') : const Text('회원가입'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
