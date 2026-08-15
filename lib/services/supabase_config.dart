class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://oiuryoaozbqafrplzanj.supabase.co';

  /// New-format Supabase publishable key (replaces the legacy JWT anon key).
  static const String publishableKey = 'sb_publishable_k39ck7vLRiDeGiRKVBnIBA_AiG13ddw';

  /// Deep link Supabase redirects back to after the Google OAuth flow.
  /// Must be added to Supabase Dashboard → Authentication → URL Configuration
  /// → Redirect URLs.
  static const String redirectUrl = 'io.salkka.app://login-callback';
}
