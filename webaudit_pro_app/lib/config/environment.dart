import 'package:flutter/foundation.dart';

/// Environment enum for staging vs production
enum Environment { staging, production }

/// Supabase configuration for each environment
class SupabaseConfig {
  final String url;
  final String anonKey;

  const SupabaseConfig({
    required this.url,
    required this.anonKey,
  });
}

/// App configuration that automatically detects environment
class AppConfig {
  /// Determines environment based on build mode
  /// Debug builds (flutter run) use staging
  /// Release builds (flutter build web) use production
  static const Environment environment = kDebugMode
      ? Environment.staging
      : Environment.production;

  /// Get the appropriate Supabase configuration for current environment
  static SupabaseConfig get supabaseConfig {
    switch (environment) {
      case Environment.staging:
        return const SupabaseConfig(
          // Staging Supabase (for testing)
          url: 'https://kmlhslmkdnjakkpluwup.supabase.co',
          anonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttbGhzbG1rZG5qYWtrcGx1d3VwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3MTQ5NzMsImV4cCI6MjA3NzI5MDk3M30.LA9ZqH3KShFU7da_25LjSJisHRkqd-8lkNlgOheNUW4',
        );

      case Environment.production:
        return const SupabaseConfig(
          // Production Supabase (live)
          url: 'https://vwnbhsmfpxdfcvqnzddc.supabase.co',
          anonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3bmJoc21mcHhkZmN2cW56ZGRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1MjAwOTMsImV4cCI6MjA3NzA5NjA5M30.2u4Fh_hrolEBeu5u_ADwZV_j3Bzq9szMBdkLZlc3b5M',
        );
    }
  }

  /// Get environment name for display
  static String get environmentName {
    return environment == Environment.staging ? 'Staging' : 'Production';
  }

  /// Get Supabase project name for display
  static String get supabaseProjectName {
    return environment == Environment.staging
        ? 'websler-pro-staging'
        : 'websler-pro';
  }
}
