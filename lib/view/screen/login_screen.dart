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
