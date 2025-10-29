import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Utility for handling PDF operations across platforms
class PdfUtils {
  /// Open PDF in a new browser tab (web only)
  /// Uses Blob URLs for browser security compliance
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

      // Create Blob from PDF bytes and open in new tab
      _openPdfBlobInNewTab(pdfBytes, filename);

      debugPrint('✅ PDF opened successfully in new tab');
      return true;
    } catch (e) {
      debugPrint('❌ Error opening PDF: $e');
      return false;
    }
  }

  /// Opens PDF Blob in browser using JavaScript Blob URLs
  /// This approach is browser-secure (avoids data URL restrictions)
  static void _openPdfBlobInNewTab(Uint8List pdfBytes, String filename) {
    try {
      // Create a Blob from the PDF bytes
      final blob = html.Blob([pdfBytes], 'application/pdf');

      // Create a Blob URL
      final blobUrl = html.Url.createObjectUrl(blob);

      // Open the Blob URL in a new tab
      html.window.open(blobUrl, '_blank');

      debugPrint('🔗 Opened blob URL: ${blobUrl.substring(0, 50)}...');
    } catch (e) {
      debugPrint('Error creating/opening PDF blob: $e');
    }
  }
}
