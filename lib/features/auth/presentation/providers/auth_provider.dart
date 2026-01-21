import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ping/features/auth/data/auth_service.dart';

/// Provider for auth service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for auth state stream
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () => null,
  );
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
