import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const String defaultDemoUserId = '5a0568e9-7c1a-4b62-a354-edf27a358963';
  static const String defaultDemoEmail = 'snap2bill.demo.tester@gmail.com';
  static bool _isDemoSession = false;

  static bool get isDemoSession => _isDemoSession;

  static Future<void> loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDemoSession = prefs.getBool('is_demo_session') ?? false;
    } catch (_) {}
  }

  static Future<void> enableDemoSession() async {
    _isDemoSession = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_demo_session', true);
    } catch (_) {}
  }

  static Future<void> clearDemoSession() async {
    _isDemoSession = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_demo_session');
    } catch (_) {}
  }

  String? get currentUserId =>
      _supabase.auth.currentUser?.id ?? (_isDemoSession ? defaultDemoUserId : null);

  String? get currentUserEmail =>
      _supabase.auth.currentUser?.email ?? (_isDemoSession ? defaultDemoEmail : null);

  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize(
        clientId: dotenv.env['GOOGLE_CLIENT_ID'],
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );
      _isInitialized = true;
    }
  }

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.origin,
        );
        return null;
      }

      await _ensureInitialized();
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'ไม่สามารถดึงข้อมูล Token จาก Google ได้';
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการล็อกอิน: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await clearDemoSession();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}
