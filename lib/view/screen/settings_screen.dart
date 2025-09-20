// File Path: lib/view/screen/settings_screen.dart
// Features:
// - SettingsScreen.build (8~10행): 설정 화면의 샘플 안내 문구를 중앙 정렬합니다.
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('설정 (샘플)'));
}
