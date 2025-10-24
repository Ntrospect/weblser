import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_state.dart';
import '../models/user.dart';
import '../database/local_db.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final LocalDatabase _localDb = LocalDatabase();
  late SharedPreferences _prefs;
  ApiService? _apiService; // Reference to ApiService for token updates

  // Auth state
  AuthState _authState = AuthState.initial();
  AppUser? _currentUser;

  // Getters
  AuthState get authState => _authState;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _authState.isAuthenticated;
  String? get authToken => _authState.authToken;
  String? get userId => _authState.userId;

  // Stream for real-time auth state changes
  Stream<AuthState> get authStateStream {
    return Stream<AuthState>.periodic(const Duration(milliseconds: 100), (_) => _authState);
  }

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Set reference to ApiService for token updates
  void setApiService(ApiService apiService) {
    _apiService = apiService;
    // Update token if already authenticated
    if (_authState.isAuthenticated && _authState.authToken != null) {
      _apiService?.setAuthToken(_authState.authToken);
    }
  }

  /// Initialize auth service and restore session
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _restoreSession();

    // Listen for Supabase auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      _handleAuthStateChange(data.session);
    });

    print('✅ AuthService initialized');
  }

  /// Restore session from SharedPreferences
  Future<void> _restoreSession() async {
    try {
      final savedUserId = _prefs.getString('user_id');
      final savedAuthToken = _prefs.getString('auth_token');
      final savedEmail = _prefs.getString('user_email');

      // Check if Supabase session is still valid
      final session = _supabase.auth.currentSession;

      if (session != null && session.user != null) {
        print('🔄 Restoring session from Supabase auth...');
        _authState = AuthState.authenticated(
          userId: session.user!.id,
          email: session.user!.email ?? '',
          authToken: session.accessToken,
          tokenExpiresAt: session.expiresAt,
        );

        // Fetch user profile from local DB or create it
        await _loadOrCreateUserProfile(session.user!.id, session.user!.email ?? '');
      } else if (savedUserId != null && savedAuthToken != null) {
        // Fall back to cached credentials
        print('🔄 Restoring cached session...');
        _authState = AuthState.authenticated(
          userId: savedUserId,
          email: savedEmail ?? '',
          authToken: savedAuthToken,
        );

        // Load user profile
        final user = await _localDb.getUserLocal(savedUserId);
        if (user != null) {
          _currentUser = AppUser.fromMap(user);
        }
      }

      notifyListeners();
    } catch (e) {
      print('⚠️ Session restore failed: $e');
      _authState = AuthState.initial();
      notifyListeners();
    }
  }

  /// Handle Supabase auth state changes
  Future<void> _handleAuthStateChange(Session? session) async {
    if (session != null && session.user != null) {
      final user = session.user!;
      _authState = AuthState.authenticated(
        userId: user.id,
        email: user.email ?? '',
        authToken: session.accessToken,
        tokenExpiresAt: session.expiresAt,
      );

      // Save to SharedPreferences
      await _prefs.setString('user_id', user.id);
      await _prefs.setString('auth_token', session.accessToken);
      await _prefs.setString('user_email', user.email ?? '');

      // Update ApiService with auth token
      _apiService?.setAuthToken(session.accessToken);

      // Load or create user profile
      await _loadOrCreateUserProfile(user.id, user.email ?? '');

      print('✅ User authenticated: ${user.email}');
    } else {
      _authState = AuthState.initial();
      _currentUser = null;

      // Clear SharedPreferences
      await _prefs.remove('user_id');
      await _prefs.remove('auth_token');
      await _prefs.remove('user_email');

      // Clear auth token from ApiService
      _apiService?.setAuthToken(null);

      print('✅ User signed out');
    }

    notifyListeners();
  }

  /// Load or create user profile
  Future<void> _loadOrCreateUserProfile(String userId, String email) async {
    try {
      // Try to load from local DB
      var userMap = await _localDb.getUserLocal(userId);

      if (userMap == null) {
        // Create new user profile in local DB
        final newUser = AppUser(
          id: userId,
          email: email,
          createdAt: DateTime.now(),
        );

        await _localDb.saveUserLocal(newUser.toMap());
        _currentUser = newUser;

        print('📝 Created new user profile: $email');
      } else {
        _currentUser = AppUser.fromMap(userMap);
        print('📂 Loaded user profile: $email');
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
    }
  }

  // ============================================
  // SIGN UP
  // ============================================

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _authState = AuthState.authenticating();
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? '',
        },
      );

      if (response.user != null) {
        print('✅ Sign up successful: $email');
        // Auth state will be updated via onAuthStateChange listener
      }
    } on AuthException catch (e) {
      _authState = AuthState.error(e.message);
      print('❌ Sign up error: ${e.message}');
    } catch (e) {
      _authState = AuthState.error('Sign up failed: $e');
      print('❌ Sign up error: $e');
    }

    notifyListeners();
  }

  // ============================================
  // SIGN IN
  // ============================================

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _authState = AuthState.authenticating();
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        print('✅ Sign in successful: $email');
        // Auth state will be updated via onAuthStateChange listener
      }
    } on AuthException catch (e) {
      _authState = AuthState.error(e.message);
      print('❌ Sign in error: ${e.message}');
    } catch (e) {
      _authState = AuthState.error('Sign in failed: $e');
      print('❌ Sign in error: $e');
    }

    notifyListeners();
  }

  // ============================================
  // SIGN OUT
  // ============================================

  /// Sign out and clear local data
  Future<void> signOut() async {
    try {
      _authState = AuthState.authenticating();
      notifyListeners();

      // Clear local database
      await _localDb.clearAllData();

      // Sign out from Supabase
      await _supabase.auth.signOut();

      _authState = AuthState.initial();
      _currentUser = null;

      // Clear SharedPreferences
      await _prefs.remove('user_id');
      await _prefs.remove('auth_token');
      await _prefs.remove('user_email');

      print('✅ Sign out successful');
    } catch (e) {
      _authState = AuthState.error('Sign out failed: $e');
      print('❌ Sign out error: $e');
    }

    notifyListeners();
  }

  // ============================================
  // PASSWORD RESET
  // ============================================

  /// Request password reset
  Future<void> resetPassword(String email) async {
    try {
      _authState = AuthState.authenticating();
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(email);

      _authState = AuthState.initial();
      print('✅ Password reset email sent: $email');
    } on AuthException catch (e) {
      _authState = AuthState.error(e.message);
      print('❌ Password reset error: ${e.message}');
    } catch (e) {
      _authState = AuthState.error('Password reset failed: $e');
      print('❌ Password reset error: $e');
    }

    notifyListeners();
  }

  // ============================================
  // TOKEN MANAGEMENT
  // ============================================

  /// Refresh auth token if expired
  Future<bool> refreshToken() async {
    try {
      if (!_authState.isTokenValid) {
        final session = await _supabase.auth.refreshSession();
        if (session != null) {
          _authState = _authState.copyWith(
            authToken: session.accessToken,
            tokenExpiresAt: session.expiresAt,
          );

          await _prefs.setString('auth_token', session.accessToken);
          print('🔄 Token refreshed');
          notifyListeners();
          return true;
        }
      }
      return true;
    } catch (e) {
      print('❌ Token refresh failed: $e');
      return false;
    }
  }

  // ============================================
  // USER PROFILE
  // ============================================

  /// Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? companyName,
    String? companyDetails,
  }) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = _currentUser!.copyWith(
        fullName: fullName,
        companyName: companyName,
        companyDetails: companyDetails,
        updatedAt: DateTime.now(),
      );

      await _localDb.saveUserLocal(updatedUser.toMap());
      _currentUser = updatedUser;

      print('✅ User profile updated');
      notifyListeners();
    } catch (e) {
      print('❌ Update profile error: $e');
    }
  }

  // ============================================
  // CLEANUP
  // ============================================

  @override
  void dispose() {
    super.dispose();
  }
}
