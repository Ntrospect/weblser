import 'dart:convert';
import 'audit_result.dart';

/// Enum for analysis type
enum AnalysisType { summary, audit }

/// Unified model for both Weblser summaries and WebAudit Pro audits
/// Allows tracking both analysis types in a single history
class WebsiteAnalysis {
  final String id;
  final String url;
  final String? title; // Page title
  final String summary; // AI summary (for summaries) or overview (for audits)
  final AnalysisType type;
  final DateTime createdAt;

  // Weblser summary fields
  final String? metaDescription; // Page meta description

  // WebAudit Pro audit fields
  final AuditResult? auditResult;
  final String? linkedSummaryId; // Reference to original summary if this is an audit

  WebsiteAnalysis({
    required this.id,
    required this.url,
    required this.summary,
    required this.type,
    required this.createdAt,
    this.title,
    this.metaDescription,
    this.auditResult,
    this.linkedSummaryId,
  });

  /// Check if this is a summary
  bool get isSummary => type == AnalysisType.summary;

  /// Check if this is an audit
  bool get isAudit => type == AnalysisType.audit;

  /// Get display name based on type
  String get displayName => isSummary ? 'Summary' : 'WebAudit Pro';

  /// Get overall score (only for audits)
  double? get overallScore => auditResult?.overallScore;

  /// Get formatted date
  String get formattedDate {
    return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
  }

  /// Get formatted time
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get formatted date and time
  String get formattedDateTime => '$formattedDate $formattedTime';

  /// Create a WebsiteAnalysis from a Weblser summary response
  factory WebsiteAnalysis.fromSummaryJson(Map<String, dynamic> json) {
    return WebsiteAnalysis(
      id: json['id'] as String? ?? '',
      url: json['url'] as String,
      title: json['title'] as String?,
      metaDescription: json['meta_description'] as String?,
      summary: json['summary'] as String,
      type: AnalysisType.summary,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Create a WebsiteAnalysis from a WebAudit Pro audit response
  factory WebsiteAnalysis.fromAuditJson(
    Map<String, dynamic> json, {
    String? linkedSummaryId,
  }) {
    final auditResult = AuditResult.fromJson(json);
    return WebsiteAnalysis(
      id: auditResult.id,
      url: auditResult.url,
      title: auditResult.websiteName,
      summary: 'Overall Score: ${auditResult.overallScore.toStringAsFixed(1)}/10',
      type: AnalysisType.audit,
      createdAt: auditResult.auditTimestamp,
      auditResult: auditResult,
      linkedSummaryId: linkedSummaryId,
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'summary': summary,
      'type': type.toString().split('.').last, // 'summary' or 'audit'
      'created_at': createdAt.toIso8601String(),
      'meta_description': metaDescription,
      'audit_result': auditResult?.toJson(),
      'linked_summary_id': linkedSummaryId,
    };
  }

  /// Create from stored JSON
  factory WebsiteAnalysis.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String? ?? 'summary';
    final type = typeString == 'audit' ? AnalysisType.audit : AnalysisType.summary;

    return WebsiteAnalysis(
      id: json['id'] as String? ?? '',
      url: json['url'] as String,
      title: json['title'] as String?,
      summary: json['summary'] as String,
      type: type,
      createdAt: DateTime.parse(json['created_at'] as String),
      metaDescription: json['meta_description'] as String?,
      auditResult: json['audit_result'] != null
          ? AuditResult.fromJson(json['audit_result'] as Map<String, dynamic>)
          : null,
      linkedSummaryId: json['linked_summary_id'] as String?,
    );
  }

  /// Create from JSON string
  static WebsiteAnalysis? fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WebsiteAnalysis.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON string for storage
  String toJsonString() {
    return jsonEncode(toJson());
  }

  @override
  String toString() {
    return 'WebsiteAnalysis(id: $id, url: $url, type: ${type.toString().split('.').last}, created: $formattedDateTime)';
  }
}
