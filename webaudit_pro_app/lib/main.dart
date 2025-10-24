import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/theme_provider.dart';
import 'services/sync_service.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://vwnbhsmfpxdfcvqnzddc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3bmJoc21mcHhkZmN2cW56ZGRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyODUzMTAsImV4cCI6MjA3Njg2MTMxMH0.2jZlqeawew5BjkqqPlab7KU0bmu9bbZMQl5Q_qaBpKA',
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
              ChangeNotifierProvider(
                create: (_) => SyncService(),
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
