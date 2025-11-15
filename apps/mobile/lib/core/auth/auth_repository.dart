import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepository {
  final supabase.SupabaseClient _supabase;

  AuthRepository(this._supabase);

  /// Sign up with email and password
  Future<supabase.AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );
    return response;
  }

  /// Sign in with email and password
  Future<supabase.AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get current session
  supabase.Session? get currentSession => _supabase.auth.currentSession;

  /// Get current user
  supabase.User? get currentUser => _supabase.auth.currentUser;

  /// Stream of auth state changes
  Stream<supabase.AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Refresh session
  Future<supabase.AuthResponse> refreshSession() async {
    final response = await _supabase.auth.refreshSession();
    return response;
  }

  /// Get access token
  String? get accessToken => _supabase.auth.currentSession?.accessToken;
}
