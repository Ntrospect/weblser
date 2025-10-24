/// Authentication state enum
enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

/// Authentication state data class
class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? authToken;
  final String? errorMessage;
  final DateTime? tokenExpiresAt;

  AuthState({
    required this.status,
    this.userId,
    this.email,
    this.authToken,
    this.errorMessage,
    this.tokenExpiresAt,
  });

  /// Convenience getters
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAuthenticating => status == AuthStatus.authenticating;
  bool get hasError => status == AuthStatus.error;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Check if token is still valid
  bool get isTokenValid {
    if (authToken == null || tokenExpiresAt == null) return false;
    return DateTime.now().isBefore(tokenExpiresAt!);
  }

  /// Create a copy with modifications
  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? authToken,
    String? errorMessage,
    DateTime? tokenExpiresAt,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      authToken: authToken ?? this.authToken,
      errorMessage: errorMessage ?? this.errorMessage,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
  }

  /// Create initial unauthenticated state
  factory AuthState.initial() {
    return AuthState(status: AuthStatus.unauthenticated);
  }

  /// Create authenticating state
  factory AuthState.authenticating() {
    return AuthState(status: AuthStatus.authenticating);
  }

  /// Create authenticated state
  factory AuthState.authenticated({
    required String userId,
    required String email,
    required String authToken,
    DateTime? tokenExpiresAt,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      userId: userId,
      email: email,
      authToken: authToken,
      tokenExpiresAt: tokenExpiresAt,
    );
  }

  /// Create error state
  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }
}
