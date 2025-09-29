import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream để theo dõi trạng thái đăng nhập
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Lấy user hiện tại
  static User? get currentUser => _auth.currentUser;

  // Kiểm tra xem user đã đăng nhập chưa
  static bool get isLoggedIn => _auth.currentUser != null;

  // Đăng nhập bằng email và password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lưu thông tin đăng nhập
      await _saveLoginInfo(email, 'email');

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi không xác định: $e';
    }
  }

  // Đăng ký tài khoản mới bằng email và password
  static Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật display name nếu có
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }

      // Lưu thông tin đăng nhập
      await _saveLoginInfo(email, 'email');

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi không xác định: $e';
    }
  }

  // Đăng nhập bằng Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Lưu thông tin đăng nhập
      await _saveLoginInfo(googleUser.email, 'google');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi khi đăng nhập bằng Google: $e';
    }
  }

  // Đăng xuất
  static Future<void> signOut() async {
    try {
      // Đăng xuất khỏi Google nếu đã đăng nhập bằng Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Đăng xuất khỏi Firebase
      await _auth.signOut();

      // Xóa thông tin đăng nhập đã lưu
      await _clearLoginInfo();
    } catch (e) {
      throw 'Đã xảy ra lỗi khi đăng xuất: $e';
    }
  }

  // Gửi email reset password
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi khi gửi email reset password: $e';
    }
  }

  // Cập nhật profile
  static Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw 'Đã xảy ra lỗi khi cập nhật profile: $e';
    }
  }

  // Lưu thông tin đăng nhập vào SharedPreferences
  static Future<void> _saveLoginInfo(String email, String loginMethod) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('login_method', loginMethod);
    await prefs.setBool('is_logged_in', true);
  }

  // Xóa thông tin đăng nhập
  static Future<void> _clearLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('login_method');
    await prefs.setBool('is_logged_in', false);
  }

  // Lấy thông tin đăng nhập đã lưu
  static Future<Map<String, String?>> getSavedLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'login_method': prefs.getString('login_method'),
    };
  }

  // Xử lý lỗi Firebase Auth
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng cho tài khoản khác.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt.';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ.';
      default:
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }
}
