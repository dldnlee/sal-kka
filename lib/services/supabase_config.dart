class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://pzsmqarpslnlblsgimhl.supabase.co';

  /// New-format Supabase publishable key (replaces the legacy JWT anon key).
  static const String publishableKey = 'sb_publishable_DyIdofiUm32f7wY0Ekr2Sg_LMuiYJ2l';

  /// Deep link Supabase redirects back to after the Google OAuth flow.
  /// Must be added to Supabase Dashboard → Authentication → URL Configuration
  /// → Redirect URLs.
  static const String redirectUrl = 'io.salkka.app://login-callback';
}
