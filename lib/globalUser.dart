import "package:flutter/material.dart";
import "package:three_line_journey/models/user.dart";

class GlobalUser extends ChangeNotifier {

  User? _user; // 사용자 객체
  User? get user => _user; // getter

  /// ✅ 사용자 설정 후 UI 업데이트
  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  /// ✅ 로그아웃
  void logout() {
    _user = null;
    notifyListeners();
  }
}
