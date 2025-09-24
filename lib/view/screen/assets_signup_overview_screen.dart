// File Path: lib/view/screen/assets_signup_overview_screen.dart
// Features:
// - AssetsSignUpOverviewScreen.build (10~12행): 유저리스트 페이지 안내 문구를 중앙에 노출합니다.
import 'package:flutter/material.dart';

class AssetsSignUpOverviewScreen extends StatelessWidget {
  const AssetsSignUpOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('유저리스트 페이지 (샘플)'),
      );
}
