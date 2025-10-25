import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_state.dart' as auth_models;
import '../models/user.dart';
import 'api_service.dart';
import 'auth_callback_handler.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  late SharedPreferences _prefs;
  ApiService? _apiService; // Reference to ApiService for token updates
  final AuthCallbackHandler _callbackHandler = AuthCallbackHandler();

  // Auth state
  auth_models.AuthState _authState = auth_models.AuthState.initial();
  AppUser? _currentUser;

  // Token monitoring state
  bool _isMonitoring = false;

  // Getters
  auth_models.AuthState get authState => _authState;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _authState.isAuthenticated;
  String? get authToken => _authState.authToken;
  String? get userId => _authState.userId;

  // Stream for real-time auth state changes
  Stream<auth_models.AuthState> get authStateStream {
    return Stream<auth_models.AuthState>.periodic(const Duration(milliseconds: 100), (_) => _authState);
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

    // Start the auth callback handler server
    await _callbackHandler.startServer();

    await _restoreSession();

    // Listen for Supabase auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      _handleAuthStateChange(data.session);
    });

    // Poll for callback tokens (checks every 500ms for 30 seconds)
    _monitorCallbackToken();

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
        final expiresAt = session.expiresAt != null
            ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
            : null;
        _authState = auth_models.AuthState.authenticated(
          userId: session.user!.id,
          email: session.user!.email ?? '',
          authToken: session.accessToken,
          tokenExpiresAt: expiresAt,
        );

        // Fetch user profile from local DB or create it
        await _loadOrCreateUserProfile(session.user!.id, session.user!.email ?? '');
      } else if (savedUserId != null && savedAuthToken != null) {
        // Fall back to cached credentials
        print('🔄 Restoring cached session...');
        _authState = auth_models.AuthState.authenticated(
          userId: savedUserId,
          email: savedEmail ?? '',
          authToken: savedAuthToken,
        );
      }

      notifyListeners();
    } catch (e) {
      print('⚠️ Session restore failed: $e');
      _authState = auth_models.AuthState.initial();
      notifyListeners();
    }
  }

  /// Handle Supabase auth state changes
  Future<void> _handleAuthStateChange(Session? session) async {
    if (session != null && session.user != null) {
      final user = session.user!;

      // Check if email is verified
      final isEmailVerified = user.userMetadata?['email_verified'] == true ||
          user.emailConfirmedAt != null;

      if (!isEmailVerified) {
        print('⚠️ Email not verified yet for: ${user.email}');
        print('💭 User will not be logged in until email is confirmed');
        _authState = auth_models.AuthState.initial();
        notifyListeners();
        return;
      }

      final expiresAt = session.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
          : null;
      _authState = auth_models.AuthState.authenticated(
        userId: user.id,
        email: user.email ?? '',
        authToken: session.accessToken,
        tokenExpiresAt: expiresAt,
      );

      // Save to SharedPreferences
      await _prefs.setString('user_id', user.id);
      await _prefs.setString('auth_token', session.accessToken);
      await _prefs.setString('user_email', user.email ?? '');

      // Update ApiService with auth token
      _apiService?.setAuthToken(session.accessToken);

      // Load or create user profile
      await _loadOrCreateUserProfile(user.id, user.email ?? '');

      print('✅ User authenticated (email verified): ${user.email}');
    } else {
      _authState = auth_models.AuthState.initial();
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

  /// Create user profile
  Future<void> _loadOrCreateUserProfile(String userId, String email) async {
    try {
      // Create new user profile
      final newUser = AppUser(
        id: userId,
        email: email,
        createdAt: DateTime.now(),
      );

      _currentUser = newUser;
      print('📝 User profile set: $email');
    } catch (e) {
      print('❌ Error setting user profile: $e');
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
      _authState = auth_models.AuthState.authenticating();
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
        print('📧 Confirmation email sent - waiting for user to verify...');

        // Check if user is already authenticated (no email verification required)
        if (response.session != null) {
          print('✅ User auto-confirmed and logged in');
          // Auth state will be updated via onAuthStateChange listener
        } else {
          // Email verification required - show "check your email" message
          print('⚠️ Email verification required for: $email');
          print('📧 Waiting for user to click confirmation link...');

          // Set authenticating state to signal UI to show "Check your email" message
          _authState = auth_models.AuthState.authenticating();

          // CRITICAL FIX: Restart monitoring for this signup attempt
          // (monitoring only runs once during app init, so we need to restart it)
          print('🔄 Restarting token monitoring for this signup...');
          _callbackHandler.clearToken(); // Clear any old token first
          _restartMonitoringForSignup();
        }
      }
    } on AuthException catch (e) {
      _authState = auth_models.AuthState.error(e.message);
      print('❌ Sign up error: ${e.message}');
    } catch (e) {
      _authState = auth_models.AuthState.error('Sign up failed: $e');
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
      _authState = auth_models.AuthState.authenticating();
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
      _authState = auth_models.AuthState.error(e.message);
      print('❌ Sign in error: ${e.message}');
    } catch (e) {
      _authState = auth_models.AuthState.error('Sign in failed: $e');
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
      _authState = auth_models.AuthState.authenticating();
      notifyListeners();

      // Sign out from Supabase
      await _supabase.auth.signOut();

      _authState = auth_models.AuthState.initial();
      _currentUser = null;

      // Clear SharedPreferences
      await _prefs.remove('user_id');
      await _prefs.remove('auth_token');
      await _prefs.remove('user_email');

      print('✅ Sign out successful');
    } catch (e) {
      _authState = auth_models.AuthState.error('Sign out failed: $e');
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
      _authState = auth_models.AuthState.authenticating();
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(email);

      _authState = auth_models.AuthState.initial();
      print('✅ Password reset email sent: $email');
    } on AuthException catch (e) {
      _authState = auth_models.AuthState.error(e.message);
      print('❌ Password reset error: ${e.message}');
    } catch (e) {
      _authState = auth_models.AuthState.error('Password reset failed: $e');
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
      final currentSession = _supabase.auth.currentSession;
      if (currentSession != null && !_authState.isTokenValid) {
        // Try to refresh the session
        try {
          await _supabase.auth.refreshSession();
          final newSession = _supabase.auth.currentSession;

          if (newSession != null) {
            final expiresAt = newSession.expiresAt != null
                ? DateTime.fromMillisecondsSinceEpoch(newSession.expiresAt! * 1000)
                : null;
            _authState = _authState.copyWith(
              authToken: newSession.accessToken,
              tokenExpiresAt: expiresAt,
            );

            await _prefs.setString('auth_token', newSession.accessToken);
            print('🔄 Token refreshed');
            notifyListeners();
            return true;
          }
        } catch (refreshErr) {
          print('❌ Token refresh failed: $refreshErr');
          return false;
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

      _currentUser = updatedUser;

      print('✅ User profile updated');
      notifyListeners();
    } catch (e) {
      print('❌ Update profile error: $e');
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      print('✅ Password updated successfully');
    } catch (e) {
      print('❌ Password update error: $e');
      throw Exception('Failed to update password: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      // Clear preferences
      await _prefs.clear();

      // Delete from Supabase
      await _supabase.auth.admin.deleteUser(_authState.userId ?? '');

      // Sign out
      await signOut();

      print('✅ Account deleted successfully');
    } catch (e) {
      print('❌ Account deletion error: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  // ============================================
  // AUTH CALLBACK MONITORING
  // ============================================

  /// Restart token monitoring for a new signup attempt
  /// This is called when a user signs up, ensuring we actively monitor for
  /// their specific verification email token.
  void _restartMonitoringForSignup() {
    if (_isMonitoring) {
      print('⚠️ Monitoring already active, skipping restart');
      return;
    }
    _monitorCallbackToken();
  }

  /// Monitor for incoming auth callback tokens
  /// Checks every 500ms for a token received via email confirmation
  void _monitorCallbackToken() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      int attempts = 0;
      const maxAttempts = 60; // 30 seconds at 500ms intervals

      print('⏱️ Starting email verification monitoring (30 second timeout)...');

      while (attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 500));

        // Check if callback handler received a token
        if (_callbackHandler.hasToken && _callbackHandler.accessToken != null) {
          print('🎉 Auth callback token detected: ${_callbackHandler.accessToken!.substring(0, 20)}...');
          await _handleCallbackToken(_callbackHandler.accessToken!);
          _callbackHandler.clearToken();
          return; // Exit monitoring
        }

        attempts++;

        // Log progress every 10 attempts (every 5 seconds)
        if (attempts % 10 == 0) {
          final secondsElapsed = attempts ~/ 2;
          print('⏳ Still waiting for email confirmation... ($secondsElapsed seconds elapsed)');
        }
      }

      // Monitoring timed out
      print('❌ Email verification monitoring timed out after 30 seconds');
      print('⚠️ The callback server may not have received the confirmation link');
      print('💡 Check that:');
      print('   1. You clicked the confirmation link in the email');
      print('   2. The link starts with http://localhost:3000');
      print('   3. Your browser can reach localhost:3000');
      print('   4. The Flask callback server is still running');
    });
  }

  /// Handle token received from email confirmation callback
  Future<void> _handleCallbackToken(String token) async {
    try {
      print('🔑 Attempting to verify email with token: $token');
      print('📍 Calling verifyOTP with type=OtpType.signup...');

      // Use the token to verify the email via Supabase OTP
      // The token from the email is an OTP that needs to be verified
      final response = await _supabase.auth.verifyOTP(
        token: token,
        type: OtpType.signup,
      );

      print('✅ verifyOTP response received');
      print('   - Session: ${response.session != null ? 'Yes' : 'No'}');
      print('   - User: ${response.user != null ? 'Yes (${response.user?.email})' : 'No'}');

      if (response.session != null && response.user != null) {
        print('✅ Email verified successfully!');
        print('✅ User authenticated: ${response.user!.email}');
        print('✅ Session token: ${response.session!.accessToken.substring(0, 20)}...');
        // Auth state will be updated via onAuthStateChange listener
      } else {
        print('⚠️ OTP verification succeeded but incomplete response');
        print('   - Setting error state and notifying listeners');
        _authState = auth_models.AuthState.error('Email verification failed - no session');
      }

      notifyListeners();
    } on AuthException catch (e) {
      print('❌ AuthException during email verification');
      print('   - Code: ${e.statusCode}');
      print('   - Message: ${e.message}');
      _authState = auth_models.AuthState.error('Email verification failed: ${e.message}');
      notifyListeners();
    } catch (e) {
      print('❌ Unexpected error handling callback token: $e');
      print('   - Type: ${e.runtimeType}');
      _authState = auth_models.AuthState.error('Token callback failed: $e');
      notifyListeners();
    }
  }

  // ============================================
  // CLEANUP
  // ============================================

  @override
  void dispose() {
    _callbackHandler.stopServer();
    super.dispose();
  }
}
