import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ping/core/monetization/revenue_cat_service.dart';

/// Service for handling user authentication with Supabase
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthService: Signing up user with email: $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      debugPrint('AuthService: Sign up successful');

      // Connect RevenueCat to new user
      if (response.user != null) {
        await RevenueCatService.instance.setUserId(response.user!.id);
        debugPrint('AuthService: RevenueCat user ID set for new user');
      }

      return response;
    } catch (e) {
      debugPrint('AuthService: Sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthService: Signing in user with email: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('AuthService: Sign in successful');

      // Connect RevenueCat to user
      if (response.user != null) {
        await RevenueCatService.instance.setUserId(response.user!.id);
        debugPrint('AuthService: RevenueCat user ID set');
      }

      return response;
    } catch (e) {
      debugPrint('AuthService: Sign in error: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      debugPrint('AuthService: Initiating Google sign in');
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.ping://login-callback/',
      );
      debugPrint('AuthService: Google sign in initiated');
      return response;
    } catch (e) {
      debugPrint('AuthService: Google sign in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      debugPrint('AuthService: Signing out user');

      // Logout from RevenueCat
      await RevenueCatService.instance.logout();
      debugPrint('AuthService: RevenueCat logout successful');

      await _supabase.auth.signOut();
      debugPrint('AuthService: Sign out successful');
    } catch (e) {
      debugPrint('AuthService: Sign out error: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      debugPrint('AuthService: Sending password reset email to: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      debugPrint('AuthService: Password reset email sent');
    } catch (e) {
      debugPrint('AuthService: Password reset error: $e');
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
