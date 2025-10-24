import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

/// Handles Supabase auth callbacks via a local HTTP server
///
/// When Supabase redirects to localhost:3000/#access_token=...,
/// this handler captures the token and makes it available to the app.
class AuthCallbackHandler {
  static final AuthCallbackHandler _instance = AuthCallbackHandler._internal();

  factory AuthCallbackHandler() => _instance;
  AuthCallbackHandler._internal();

  HttpServer? _server;
  static const int _port = 3000;

  // Callback storage
  String? _accessToken;
  String? _refreshToken;
  String? _type;
  int? _expiresIn;
  int? _expiresAt;

  // Getters
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get type => _type;
  int? get expiresIn => _expiresIn;
  int? get expiresAt => _expiresAt;

  bool get hasToken => _accessToken != null;

  /// Start the local auth callback server
  Future<void> startServer() async {
    try {
      final handler = shelf.Pipeline()
          .addMiddleware(shelf.logRequests())
          .addHandler(_handleRequest);

      _server = await shelf_io.serve(
        handler,
        'localhost',
        _port,
      );

      print('🔐 Auth callback server started on localhost:$_port');
    } catch (e) {
      print('⚠️ Failed to start auth callback server: $e');
      // Don't throw - app should continue even if callback fails
    }
  }

  /// Handle incoming requests
  Future<shelf.Response> _handleRequest(shelf.Request request) async {
    try {
      final uri = request.url;
      print('📨 Received request: $uri');
      print('📨 Full URL: ${request.requestedUri}');
      print('📨 Fragment: "${uri.fragment}"');
      print('📨 Path: ${uri.path}');
      print('📨 Query: ${uri.query}');
      print('📨 Headers: ${request.headers}');

      // Try to get token from fragment first (URL hash)
      if (uri.fragment.isNotEmpty) {
        print('📨 Parsing fragment...');
        final params = _parseFragment(uri.fragment);
        print('📨 Fragment params: $params');

        _accessToken = params['access_token'];
        _refreshToken = params['refresh_token'];
        _type = params['type'];
        _expiresIn = params['expires_in'] != null
            ? int.tryParse(params['expires_in']!)
            : null;
        _expiresAt = params['expires_at'] != null
            ? int.tryParse(params['expires_at']!)
            : null;

        if (_accessToken != null) {
          final preview = _accessToken!.length > 20
              ? _accessToken!.substring(0, 20) + '...'
              : _accessToken!;
          print('✅ Auth token received from fragment: $preview (length: ${_accessToken!.length})');
          return _successResponse();
        }
      }

      // Fallback: check query parameters (in case fragment was lost)
      if (uri.queryParameters.isNotEmpty) {
        print('📨 Parsing query parameters...');
        print('📨 Query params: ${uri.queryParameters}');

        // Supabase email template uses 'token' parameter, not 'access_token'
        _accessToken = uri.queryParameters['token'] ?? uri.queryParameters['access_token'];
        _refreshToken = uri.queryParameters['refresh_token'];
        _type = uri.queryParameters['type'];
        _expiresIn = uri.queryParameters['expires_in'] != null
            ? int.tryParse(uri.queryParameters['expires_in']!)
            : null;
        _expiresAt = uri.queryParameters['expires_at'] != null
            ? int.tryParse(uri.queryParameters['expires_at']!)
            : null;

        if (_accessToken != null) {
          final preview = _accessToken!.length > 20
              ? _accessToken!.substring(0, 20) + '...'
              : _accessToken!;
          print('✅ Auth token received from query: $preview (length: ${_accessToken!.length})');
          print('✅ Token type: ${_type ?? "unknown"}');
          return _successResponse();
        }
      }

      print('⚠️ No token found in fragment or query parameters');
      return _errorResponse('No auth token found in request');
    } catch (e) {
      print('❌ Error handling auth callback: $e');
      return _errorResponse('Error: $e');
    }
  }

  /// Parse URL fragment (hash parameters)
  Map<String, String> _parseFragment(String fragment) {
    final params = <String, String>{};
    for (var param in fragment.split('&')) {
      if (param.contains('=')) {
        final parts = param.split('=');
        final key = Uri.decodeComponent(parts[0]);
        final value = Uri.decodeComponent(parts[1]);
        params[key] = value;
      }
    }
    return params;
  }

  /// Success response HTML
  shelf.Response _successResponse() {
    return shelf.Response.ok(
      '''
      <!DOCTYPE html>
      <html>
        <head>
          <title>Email Confirmed</title>
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              margin: 0;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            }
            .container {
              background: white;
              padding: 40px;
              border-radius: 12px;
              box-shadow: 0 20px 60px rgba(0,0,0,0.3);
              text-align: center;
              max-width: 400px;
            }
            h1 { color: #333; margin-top: 0; }
            p { color: #666; line-height: 1.6; }
            .success {
              font-size: 48px;
              margin-bottom: 20px;
            }
            .info {
              background: #f0f4ff;
              padding: 16px;
              border-radius: 8px;
              color: #667eea;
              font-size: 14px;
              margin-top: 20px;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="success">✅</div>
            <h1>Email Confirmed!</h1>
            <p>Your email has been verified successfully.</p>
            <p style="font-weight: bold;">You can now close this page and return to the app.</p>
            <div class="info">
              The WebAudit Pro app will log you in automatically.
            </div>
          </div>
        </body>
      </html>
      ''',
      headers: {'Content-Type': 'text/html; charset=utf-8'},
    );
  }

  /// Error response HTML
  shelf.Response _errorResponse(String message) {
    return shelf.Response.forbidden(
      '''
      <!DOCTYPE html>
      <html>
        <head>
          <title>Authentication Error</title>
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              margin: 0;
              background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            }
            .container {
              background: white;
              padding: 40px;
              border-radius: 12px;
              box-shadow: 0 20px 60px rgba(0,0,0,0.3);
              text-align: center;
              max-width: 400px;
            }
            h1 { color: #d32f2f; margin-top: 0; }
            p { color: #666; line-height: 1.6; }
            .error {
              font-size: 48px;
              margin-bottom: 20px;
            }
            .code {
              background: #f5f5f5;
              padding: 12px;
              border-radius: 4px;
              font-family: monospace;
              font-size: 12px;
              overflow-x: auto;
              margin-top: 16px;
              text-align: left;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="error">❌</div>
            <h1>Authentication Failed</h1>
            <p>There was an issue with your email verification:</p>
            <div class="code">$message</div>
            <p>Please try signing up again or contact support.</p>
          </div>
        </body>
      </html>
      ''',
      headers: {'Content-Type': 'text/html; charset=utf-8'},
    );
  }

  /// Stop the server
  Future<void> stopServer() async {
    await _server?.close(force: true);
    print('🛑 Auth callback server stopped');
  }

  /// Clear stored token
  void clearToken() {
    _accessToken = null;
    _refreshToken = null;
    _type = null;
    _expiresIn = null;
    _expiresAt = null;
  }
}
