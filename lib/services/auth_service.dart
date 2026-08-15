import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  AuthService() {
    _client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: SupabaseConfig.redirectUrl,
    );
  }

  /// Creates a new account. If email confirmation is required by the
  /// project's auth settings, [AuthResponse.session] will be null until the
  /// user confirms via the link sent to their inbox.
  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Fetches { income_type, income_amount } for the signed-in user, or null
  /// if not signed in / no row saved yet.
  Future<Map<String, dynamic>?> fetchIncomeProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    return _client
        .from('profiles')
        .select('income_type, income_amount')
        .eq('id', uid)
        .maybeSingle();
  }

  Future<void> saveIncomeProfile({
    required String incomeType,
    required double incomeAmount,
  }) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    await _client.from('profiles').upsert({
      'id': uid,
      'income_type': incomeType,
      'income_amount': incomeAmount,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
