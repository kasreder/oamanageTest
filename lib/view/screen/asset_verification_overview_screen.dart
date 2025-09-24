// File Path: lib/view/screen/asset_verification_overview_screen.dart
// Features:
// - AssetVerificationOverviewScreen.build (10~12행): 실사 확인 페이지 소개 문구를 중앙의 텍스트로 표시합니다.
import 'package:flutter/material.dart';

class AssetVerificationOverviewScreen extends StatelessWidget {
  const AssetVerificationOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('실사 확인 페이지 (샘플)'),
      );
}
