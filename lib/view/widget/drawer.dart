import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import 'loginout_widget.dart';

/// 앱 전체에 쓰이는 좌측 Drawer
class BaseDrawer extends StatefulWidget {
  const BaseDrawer({ super.key });

  @override
  State<BaseDrawer> createState() => _BaseDrawerState();
}

class _BaseDrawerState extends State<BaseDrawer> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.username.isNotEmpty;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          /// 상단 헤더 (로고/로그인 박스)
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xffce93d8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('COSMOSX',style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LoginStyle2(),
                  ],
                ),
              ],
            ),
          ),

          /// 메뉴: 자산
          ListTile(
            title: const Text('자산'),
            onTap: () {
              context.go('/asset');
              Navigator.pop(context);
            },
          ),

          /// 메뉴: 도면
          ListTile(
            title: const Text('도면'),
            onTap: () {
              context.go('/drawing');
              Navigator.pop(context);
            },
          ),

          /// 메뉴: 커뮤니티
          ExpansionTile(
            title: const Text('커뮤니티'),
            children: <Widget>[
              ListTile(
                  title: const Text('-  실사 확인 페이지'),
                  onTap: () {
                    context.go('/assetVerification', extra: UniqueKey());
                  }),
              ListTile(
                  title: const Text('-  유저리스트 페이지'),
                  onTap: () {
                    context.go('/assetsSignUp', extra: UniqueKey());
                    Navigator.pop(context);
                  }),
            ],
          ),

          /// 설정
          ListTile(
              title: const Text('설정'),
              onTap: () {
                context.go('/set');
                Navigator.pop(context);
              }),
          /// 로그인/회원정보
          ListTile(
            title: Text(isLoggedIn ? '회원정보' : 'LOGIN'),
            onTap: () {
              if (isLoggedIn) {
                context.go('/member');
              } else {
                context.go('/login');
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
