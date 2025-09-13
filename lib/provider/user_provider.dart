import 'package:flutter/material.dart';

/// 간단한 로그인 상태 관리
class UserProvider extends ChangeNotifier {
  String username = '';

  bool get isLoggedIn => username.isNotEmpty;

  void login(String name) {
    username = name;
    notifyListeners();
  }

  void logout() {
    username = '';
    notifyListeners();
  }
}
