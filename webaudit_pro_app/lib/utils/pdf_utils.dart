import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:js/js.dart';

/// Utility for handling PDF operations across platforms
class PdfUtils {
  /// Open PDF in a new browser tab (web only)
  /// Uses base64 data URL approach for maximum compatibility
  /// Returns true if successful, false otherwise
  static Future<bool> openPdfInNewTab(
    Uint8List pdfBytes,
    String filename,
  ) async {
    if (!kIsWeb) {
      debugPrint('⚠️ openPdfInNewTab only supported on web platform');
      return false;
    }

    try {
      debugPrint('🔍 Opening PDF in new tab: $filename');

      // Convert PDF bytes to base64
      final base64Pdf = base64Encode(pdfBytes);

      // Create data URL
      final dataUrl = 'data:application/pdf;base64,$base64Pdf';

      // Open in new tab using JavaScript interop
      _openPdfInBrowser(dataUrl);

      debugPrint('✅ PDF opened successfully in new tab');
      return true;
    } catch (e) {
      debugPrint('❌ Error opening PDF: $e');
      return false;
    }
  }

  /// Opens PDF in browser using JavaScript
  static void _openPdfInBrowser(String dataUrl) {
    try {
      // Call JavaScript window.open function
      _jsOpenInNewTab(dataUrl);
    } catch (e) {
      debugPrint('Error opening PDF in browser: $e');
    }
  }
}

// JavaScript interop declarations
@JS()
external void eval(String code);

@JS('window.open')
external dynamic _jsOpenInNewTab(String url, [String target]);
