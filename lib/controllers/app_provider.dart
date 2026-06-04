import 'package:flutter/foundation.dart';

/// Base application provider for later app-level state management.
class AppProvider extends ChangeNotifier {
  bool _isBusy = false;

  bool get isBusy => _isBusy;

  void setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
  }
}
