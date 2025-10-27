import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/theme_provider.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    print('✅ .env file loaded successfully');
  } catch (e) {
    print('⚠️ Note: .env file not found, using hardcoded credentials');
    // Fallback to hardcoded credentials if .env is not available
  }

  // Get Supabase credentials from .env or use hardcoded fallback
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
      'https://vwnbhsmfpxdfcvqnzddc.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3bmJoc21mcHhkZmN2cW56ZGRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1MjAwOTMsImV4cCI6MjA3NzA5NjA5M30.2u4Fh_hrolEBeu5u_ADwZV_j3Bzq9szMBdkLZlc3b5M';

  // Verify credentials are available
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('Supabase credentials not configured. Check .env file or hardcoded values.');
  }

  print('🔐 Supabase URL: $supabaseUrl');
  print('🔐 Initializing Supabase...');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  print('✅ Supabase initialized successfully');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => AuthService(),
              ),
              ChangeNotifierProvider(
                create: (_) => ThemeProvider(snapshot.data!),
              ),
              ChangeNotifierProvider(
                create: (_) => ApiService(snapshot.data!),
              ),
            ],
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return MaterialApp(
                  title: 'WebAudit Pro - Website Audit Tool',
                  theme: themeProvider.isDarkMode
                      ? DarkAppTheme.darkTheme
                      : LightAppTheme.lightTheme,
                  home: const AuthWrapper(),
                );
              },
            ),
          );
        }
        // Show loading screen while initializing SharedPreferences
        // Wrap with MaterialApp to provide Directionality context
        return MaterialApp(
          title: 'WebAudit Pro - Website Audit Tool',
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            backgroundColor: const Color(0xFFF6F8FF),
            body: const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
