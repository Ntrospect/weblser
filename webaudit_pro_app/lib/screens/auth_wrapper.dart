import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../models/auth_state.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;
  bool _showSignup = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final authService = context.read<AuthService>();
    final apiService = context.read<ApiService>();

    // Wire services together
    authService.setApiService(apiService);

    // Initialize auth and restore session
    await authService.initialize();

    // Hide splash after initialization
    if (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _showSplash = false);
    }
  }

  void _switchToSignup() {
    setState(() => _showSignup = true);
  }

  void _switchToLogin() {
    setState(() => _showSignup = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Show splash while initializing
        if (_showSplash) {
          return const SplashScreen(
            onSplashComplete: null, // Splash will auto-hide after 2 seconds
          );
        }

        // If authenticated, show main app
        if (authService.isAuthenticated) {
          return const MainApp();
        }

        // If authenticating, show loading
        if (authService.authState.status == AuthStatus.authenticating) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    authService.authState.email ?? 'Signing in...',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // Show signup or login screen
        if (_showSignup) {
          return SignupScreen(
            onSwitchToLogin: _switchToLogin,
          );
        } else {
          return LoginScreen(
            onSwitchToSignup: _switchToSignup,
          );
        }
      },
    );
  }
}

/// Main app widget (Home, History, Settings)
class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  bool _isScrolled = false;

  /// Clean navigation structure:
  /// - Home: Websler summary generator
  /// - History: Unified history (summaries + audits with upgrade option)
  /// - Settings: Theme & preferences
  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isScrolled = false;
    });
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final isScrolled = notification.metrics.pixels > 10;
      if (isScrolled != _isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final bgColor = themeProvider.isDarkMode
            ? const Color(0xFF0F1419)
            : Colors.white;
        final scrolledBgColor = themeProvider.isDarkMode
            ? const Color(0xFF0F1419).withOpacity(0.95)
            : Colors.white.withOpacity(0.8);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            toolbarHeight: 68,
            elevation: 0,
            backgroundColor: _isScrolled ? scrolledBgColor : bgColor,
            surfaceTintColor: bgColor,
            title: Consumer<AuthService>(
              builder: (context, authService, _) {
                return SizedBox(
                  width: 165,
                  height: 69,
                  child: Image.asset(
                    'assets/websler_pro.png',
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 32),
                child: SizedBox(
                  width: 151,
                  height: 54,
                  child: Image.asset(
                    'assets/jumoki_coloured_transparent_bg.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _onScroll(notification);
              return false;
            },
            child: _screens[_selectedIndex],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}
