import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../models/analysis.dart';
import '../models/audit_result.dart';

class ApiService extends ChangeNotifier {
  final SharedPreferences _prefs;
  late String _apiUrl;

  static const String _apiUrlKey = 'api_url';
  static const String _defaultApiUrl = 'http://140.99.254.83:8000';

  ApiService(this._prefs) {
    _apiUrl = _prefs.getString(_apiUrlKey) ?? _defaultApiUrl;
  }

  String get apiUrl => _apiUrl;

  void setApiUrl(String url) {
    _apiUrl = url;
    _prefs.setString(_apiUrlKey, url);
    notifyListeners();
  }

  Future<Analysis> analyzeUrl(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/api/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Analysis.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to analyze URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing URL: $e');
    }
  }

  Future<List<Analysis>> getHistory({int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/api/history?limit=$limit'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final analyses = (data['analyses'] as List)
            .map((item) => Analysis.fromJson(item))
            .toList();
        return analyses;
      } else {
        throw Exception('Failed to get history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }

  Future<Analysis> getAnalysis(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/api/analyses/$id'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Analysis.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching analysis: $e');
    }
  }

  Future<String> generatePdf(
    String analysisId, {
    String? logoUrl,
    String? companyName,
    String? companyDetails,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/api/pdf'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'analysis_id': analysisId,
          'logo_url': logoUrl,
          'company_name': companyName,
          'company_details': companyDetails,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Get the downloads directory
        final Directory? downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null) {
          throw Exception('Could not access Downloads directory');
        }

        // Create filename with timestamp
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String filename = 'weblser-analysis-$timestamp.pdf';
        final String filepath = '${downloadsDir.path}/$filename';

        // Save PDF file
        final File file = File(filepath);
        await file.writeAsBytes(response.bodyBytes);

        return filepath;
      } else {
        throw Exception('Failed to generate PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating PDF: $e');
    }
  }

  Future<void> deleteAnalysis(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/api/analyses/$id'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting analysis: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/api/history'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to clear history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error clearing history: $e');
    }
  }

  // ==================== WebAudit Pro - Audit Methods ====================

  /// Run a comprehensive 10-point audit on a website
  Future<AuditResult> auditWebsite(
    String url, {
    int timeout = 60,
    bool deepScan = true,
  }) async {
    try {
      debugPrint('🔍 Starting audit for URL: $url');
      debugPrint('📡 API URL: $_apiUrl/api/audit/analyze');

      final response = await http.post(
        Uri.parse('$_apiUrl/api/audit/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'url': url,
          'timeout': timeout,
          'deep_scan': deepScan,
        }),
      ).timeout(Duration(seconds: timeout + 60));

      debugPrint('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Audit successful');
        return AuditResult.fromJson(jsonDecode(response.body));
      } else {
        final errorBody = response.body;
        debugPrint('❌ Server error: ${response.statusCode}');
        debugPrint('📝 Response body: $errorBody');
        throw Exception('Server error ${response.statusCode}: $errorBody');
      }
    } on TimeoutException catch (e) {
      debugPrint('⏱️ Request timeout: $e');
      throw Exception('Request timeout - audit took too long. Please try again.');
    } catch (e) {
      debugPrint('🔴 Error auditing website: $e');
      throw Exception('Error auditing website: $e');
    }
  }

  /// Get a specific audit result by ID
  Future<AuditResult> getAudit(String auditId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/api/audit/$auditId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AuditResult.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get audit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching audit: $e');
    }
  }

  /// Get audit history
  Future<List<AuditResult>> getAuditHistory({int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/api/audit/history/list?limit=$limit'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audits = (data['audits'] as List)
            .map((item) => AuditResult.fromJson(item as Map<String, dynamic>))
            .toList();
        return audits;
      } else {
        throw Exception('Failed to get audit history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching audit history: $e');
    }
  }

  /// Generate PDF report for an audit
  /// documentType: "audit-report", "improvement-plan", or "partnership-proposal"
  Future<String> generateAuditPdf(
    String auditId,
    String documentType, {
    String? clientName,
    String companyName = 'WebAudit Pro',
    String? companyDetails,
  }) async {
    try {
      // Validate document type
      const validTypes = ['audit-report', 'improvement-plan', 'partnership-proposal'];
      if (!validTypes.contains(documentType)) {
        throw Exception('Invalid document type: $documentType');
      }

      final response = await http.post(
        Uri.parse('$_apiUrl/api/audit/generate-pdf/$auditId/$documentType'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'audit_id': auditId,
          'document_type': documentType,
          'client_name': clientName,
          'company_name': companyName,
          'company_details': companyDetails,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        // Get the downloads directory
        final Directory? downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null) {
          throw Exception('Could not access Downloads directory');
        }

        // Create filename based on document type
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String filename = 'webaudit-$documentType-$timestamp.pdf';
        final String filepath = '${downloadsDir.path}/$filename';

        // Save PDF file
        final File file = File(filepath);
        await file.writeAsBytes(response.bodyBytes);

        return filepath;
      } else {
        throw Exception('Failed to generate PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating PDF: $e');
    }
  }

  /// Delete an audit from history
  Future<void> deleteAudit(String auditId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/api/audit/$auditId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete audit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting audit: $e');
    }
  }

  /// Clear all audit history
  Future<void> clearAuditHistory() async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/api/audit/history/clear'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to clear audit history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error clearing audit history: $e');
    }
  }
}
