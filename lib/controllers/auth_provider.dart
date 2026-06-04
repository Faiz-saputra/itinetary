import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/services/auth_service.dart';

/// AuthProvider
///
/// Mengelola state authentication di level aplikasi menggunakan [ChangeNotifier].
/// Berinteraksi dengan [AuthService] untuk operasi auth, meng-handle loading
/// state, dan memaparkan pesan error yang ramah.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _init();
  }

  final AuthService _authService = AuthService.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<User?>? _authSub;

  // ---------- Getters (public) ----------

  /// Current Firebase user if logged in, otherwise `null`.
  User? get user => _user;

  /// Whether an auth operation is in progress.
  bool get isLoading => _isLoading;

  /// Last error message (friendly) or `null`.
  String? get errorMessage => _errorMessage;

  /// Convenience getter to check if user is logged in.
  bool get isLoggedIn => _user != null;

  /// Firebase auth state change stream.
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // ---------- Public methods (actions) ----------

  /// Initialize provider: subscribe to auth state changes.
  void _init() {
    _authSub = _authService.authStateChanges.listen((u) {
      _user = u;
      notifyListeners();
    });
    // Also set initial user if already signed in
    _user = _authService.currentUser;
  }

  /// Clear previous error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Internal helper to set loading state.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Login using email & password. Returns `true` when successful.
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final cred = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      _user = cred.user;
      return true;
    } on Exception catch (e) {
      _errorMessage = _formatExceptionMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new user using email & password. Returns `true` when successful.
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final cred = await _authService.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      _user = cred.user;
      return true;
    } on Exception catch (e) {
      _errorMessage = _formatExceptionMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send a password reset email. Returns `true` when the email was sent.
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.resetPassword(email: email);
      return true;
    } on Exception catch (e) {
      _errorMessage = _formatExceptionMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout current user.
  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.logout();
      _user = null;
    } on Exception catch (e) {
      _errorMessage = _formatExceptionMessage(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Check session synchronously (useful on app start).
  void checkSession() {
    _user = _authService.currentUser;
    notifyListeners();
  }

  // ---------- Helpers ----------

  String _formatExceptionMessage(Exception e) {
    final raw = e.toString();
    // AuthService throws `Exception('message')` — strip the wrapper if present.
    if (raw.startsWith('Exception:')) {
      return raw.replaceFirst('Exception:', '').trim();
    }
    return raw;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
