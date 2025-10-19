import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/analysis.dart';

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
        // Return the PDF as base64 or save it
        return base64Encode(response.bodyBytes);
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
}
