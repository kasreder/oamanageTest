// File Path: lib/view/screen/news_screen.dart
// Features:
// - NewsScreen.build (8~10행): 뉴스 목록 화면의 샘플 텍스트를 중앙에 렌더링합니다.
import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('뉴스 목록 (샘플)'));
}
