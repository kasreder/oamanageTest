// File Path: lib/view/screen/login_screen.dart
// Features:
// - LoginScreen.build (18~39행): 로그인 화면 스캐폴드를 구성하고 입력 필드와 버튼을 배치합니다.
// - FilledButton.onPressed (27~33행): 사용자 이름을 검증해 UserProvider.login 호출 후 이전 화면으로 돌아갑니다.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: ctrl, decoration: const InputDecoration(labelText: '사용자 이름')),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  context.read<UserProvider>().login(ctrl.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
