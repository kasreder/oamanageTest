// File Path: lib/view/screen/free_screen.dart
// Features:
// - FreeScreen.build (8~10행): 자유게시판 샘플 문구를 중앙의 텍스트로 표시합니다.
import 'package:flutter/material.dart';

class FreeScreen extends StatelessWidget {
  const FreeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('자유게시판 (샘플)'));
}
