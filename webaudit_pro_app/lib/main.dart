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
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with credentials from environment variables
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(
      'Missing Supabase credentials in .env file. '
      'Please copy .env.example to .env and add your credentials.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

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
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FF),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
