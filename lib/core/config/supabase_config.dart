class SupabaseConfig {
  // TODO: Replace with your actual Supabase project credentials
  // Get these from: https://app.supabase.com/project/_/settings/api

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hlnixhoofjzwmoscnurk.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsbml4aG9vZmp6d21vc2NudXJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg5MzEwMzYsImV4cCI6MjA4NDUwNzAzNn0.osMeMJgdjtP-sEeRMmfreQSRzkYbNWx8qCAItwchdN8',
  );

  // Helper to check if configured
  static bool get isConfigured {
    return !supabaseUrl.contains('https://hlnixhoofjzwmoscnurk.supabase.co') &&
        !supabaseAnonKey.contains(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsbml4aG9vZmp6d21vc2NudXJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg5MzEwMzYsImV4cCI6MjA4NDUwNzAzNn0.osMeMJgdjtP-sEeRMmfreQSRzkYbNWx8qCAItwchdN8');
  }
}
