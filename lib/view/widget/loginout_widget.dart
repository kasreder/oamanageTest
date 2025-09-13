import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';

/// Drawer Header 안에 들어갈 로그인/로그아웃 UI
class LoginStyle2 extends StatelessWidget {
  const LoginStyle2({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    if (user.isLoggedIn) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Hi, ${user.username}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: () => context.go('/member'),
            child: const Text('회원정보'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => user.logout(),
            child: const Text('로그아웃'),
          ),
        ],
      );
    }
    return FilledButton(
      onPressed: () => context.go('/login'),
      child: const Text('Login'),
    );
  }
}
