/// Connection settings for the ReCan Supabase project.
///
/// Both values are public by design: the publishable key only identifies the
/// project, and every table is protected by Row Level Security. Never put a
/// secret or service_role key here. Override at build time with
/// `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_PUBLISHABLE_KEY=...`.
class SupabaseConfig {
  const new _();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lhbjzjoejmdvhlzhcbgm.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_hSdKYnhQhtu5P6y65URfog_dy9xbXd1',
  );
}
