import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// AuthService
///
/// Penyedia fungsi authentication yang membungkus `FirebaseAuth` dan Firestore.
/// - Mengembalikan `UserCredential` untuk operasi yang berhasil (login/register)
/// - Menyimpan profil pengguna ke koleksi `users`
/// - Melempar `Exception` dengan pesan yang rapi ketika terjadi error
/// - Tidak berisi kode UI — hanya logic service
class AuthService {
  AuthService._private();
  static final AuthService instance = AuthService._private();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current signed-in user or `null` if none.
  User? get currentUser => _auth.currentUser;

  /// Stream yang memancarkan perubahan authentication state.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email & password.
  ///
  /// Returns the [UserCredential] on success.
  /// Throws [Exception] with friendly message on failure.
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      // Map Firebase error codes to friendly messages
      throw Exception(_mapFirebaseAuthError(e));
    } catch (e) {
      throw Exception('Login gagal: ${e.toString()}');
    }
  }

  /// Register a new user with email & password.
  ///
  /// Returns the [UserCredential] on success.
  /// Throws [Exception] with friendly message on failure.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Gagal membuat akun. Silakan coba lagi.');
      }

      await _saveUserProfile(user, fullName);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } on FirebaseException catch (e) {
      throw Exception('Penyimpanan profil gagal: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Pendaftaran gagal: ${e.toString()}');
    }
  }

  Future<void> _saveUserProfile(User user, String fullName) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      await _deleteUserOnFailure(user);
      throw Exception('Profil pengguna sudah ada. Silakan login.');
    }

    await userRef.set({
      'uid': user.uid,
      'fullName': fullName.trim(),
      'email': user.email?.trim().toLowerCase() ?? '',
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> _deleteUserOnFailure(User user) async {
    try {
      await user.delete();
    } catch (_) {
      // Ignore cleanup failures so the original error is propagated.
    }
  }

  /// Sends password reset email to the provided [email].
  ///
  /// Throws [Exception] with friendly message on failure.
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } catch (e) {
      throw Exception('Gagal mengirim reset password: ${e.toString()}');
    }
  }

  /// Sign out the current user.
  ///
  /// Throws [Exception] on failure.
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Gagal logout: ${e.toString()}');
    }
  }

  /// Map FirebaseAuthException codes to readable Indonesian messages.
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Alamat email tidak valid.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan. Silakan hubungi dukungan.';
      case 'user-not-found':
        return 'Pengguna tidak ditemukan. Silakan periksa email Anda.';
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login atau gunakan email lain.';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan. Silakan cek konfigurasi Firebase.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan kombinasi huruf dan angka minimal 6 karakter.';
      case 'network-request-failed':
        return 'Gagal terhubung ke jaringan. Periksa koneksi internet Anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        // Return the original message when available, otherwise a generic one
        return e.message ?? 'Terjadi kesalahan otentikasi.';
    }
  }
}
