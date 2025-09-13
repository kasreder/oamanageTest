import 'package:flutter/material.dart';

/// navigation.dart에서 사용하는 더미 Provider1111111
/// 실제 API 연동 전, 화면 전환 시 카운트만 증가시키는 용도
class ViewCountProvider extends ChangeNotifier {
  int assetCount = 0;
  int freeCount = 0;
  int recordCount = 0;
  int drawingCount = 0;

  Future<void> fetchPostDataFromAPI(String board) async {
    await Future.delayed(const Duration(milliseconds: 200));
    switch (board) {
      case 'asset':
        assetCount++;
        break;
      case 'free':
        freeCount++;
        break;
      case 'record':
        recordCount++;
        break;
      case 'drawing':
        drawingCount++;
        break;
    }
    notifyListeners();
  }
}
