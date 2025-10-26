import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loader
/// Provides centralized access to environment variables
class EnvConfig {
  static String? _cachedApiUrl;

  /// Get API base URL from environment or return default
  static String getApiUrl() {
    _cachedApiUrl ??= dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
    return _cachedApiUrl!;
  }

  /// Get Supabase URL from environment
  static String? getSupabaseUrl() {
    return dotenv.env['SUPABASE_URL'];
  }

  /// Get Supabase anon key from environment
  static String? getSupabaseAnonKey() {
    return dotenv.env['SUPABASE_ANON_KEY'];
  }

  /// Get Supabase service role key from environment (backend only!)
  static String? getSupabaseServiceRoleKey() {
    return dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
  }

  /// Get environment (development, staging, production)
  static String getEnvironment() {
    return dotenv.env['ENVIRONMENT'] ?? 'development';
  }

  /// Check if in production environment
  static bool isProduction() {
    return getEnvironment() == 'production';
  }
}
