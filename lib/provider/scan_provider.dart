import 'package:flutter/material.dart';

/// 스캔된 코드 저장(최근 1건 + 히스토리), 재등록 여부 판정
class ScanProvider extends ChangeNotifier {
  String? lastCode;        // 마지막으로 읽힌 코드
  DateTime? lastAt;        // 읽힌 시간
  bool isReregister = false; // 재등록 여부

  final Set<String> _seen = {};     // 이미 본 코드들(로컬 mock)
  final List<String> history = [];  // 최근 스캔 기록

  /// 스캔 기록을 추가하고 재등록 여부를 결정
  void record(String code) {
    final existed = _seen.contains(code);
    isReregister = existed;

    lastCode = code;
    lastAt = DateTime.now();

    if (!existed) _seen.add(code);
    history.insert(0, code);
    if (history.length > 50) {
      history.removeLast();
    }
    notifyListeners();
  }

  /// 최근값 초기화
  void clearLast() {
    lastCode = null;
    lastAt = null;
    isReregister = false;
    notifyListeners();
  }
}
