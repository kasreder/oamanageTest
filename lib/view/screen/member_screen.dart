import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';

class MemberScreen extends StatelessWidget {
  const MemberScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('회원정보')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(user.isLoggedIn ? '회원: ${user.username}' : '로그인 필요'),
            const SizedBox(height: 12),
            if (user.isLoggedIn)
              OutlinedButton(
                onPressed: () => user.logout(),
                child: const Text('로그아웃'),
              ),
          ],
        ),
      ),
    );
  }
}
