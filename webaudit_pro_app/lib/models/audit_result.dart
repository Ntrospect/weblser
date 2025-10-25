import 'dart:convert';

/// Represents a website audit result with 10 criterion scores
class AuditResult {
  final String id;
  final String url;
  final String websiteName;
  final DateTime auditTimestamp;
  final double overallScore; // 0-100
  final Map<String, double> scores; // 10 criteria: 0-10
  final List<String> keyStrengths;
  final List<String> criticalIssues;
  final List<Recommendation> priorityRecommendations;

  AuditResult({
    required this.id,
    required this.url,
    required this.websiteName,
    required this.auditTimestamp,
    required this.overallScore,
    required this.scores,
    required this.keyStrengths,
    required this.criticalIssues,
    required this.priorityRecommendations,
  });

  /// Get score for a specific criterion
  double getScore(String criterion) {
    return scores[criterion] ?? 0.0;
  }

  /// Get color indicator for a score (0-10)
  /// Green: 8-10, Orange: 6-8, Red: 0-6
  String getScoreColor(double score) {
    if (score >= 8) return 'green';
    if (score >= 6) return 'orange';
    return 'red';
  }

  /// Get status text for a score
  String getScoreStatus(double score) {
    if (score >= 8) return 'Excellent';
    if (score >= 6) return 'Good';
    if (score >= 4) return 'Needs Work';
    return 'Critical';
  }

  /// Parse from JSON response from backend
  factory AuditResult.fromJson(Map<String, dynamic> json) {
    return AuditResult(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      websiteName: json['website_name'] as String? ?? '',
      auditTimestamp: json['audit_timestamp'] != null
          ? DateTime.parse(json['audit_timestamp'] as String)
          : DateTime.now(),
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0.0,
      scores: Map<String, double>.from(
        json['scores']?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {}
      ),
      keyStrengths: List<String>.from(json['key_strengths'] as List? ?? []),
      criticalIssues: List<String>.from(json['critical_issues'] as List? ?? []),
      priorityRecommendations: (json['priority_recommendations'] as List?)
              ?.map((rec) => Recommendation.fromJson(rec as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'website_name': websiteName,
      'audit_timestamp': auditTimestamp.toIso8601String(),
      'overall_score': overallScore,
      'scores': scores,
      'key_strengths': keyStrengths,
      'critical_issues': criticalIssues,
      'priority_recommendations': priorityRecommendations.map((r) => r.toJson()).toList(),
    };
  }

  /// Create from stored JSON string
  static AuditResult? fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuditResult.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON string for storage
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Get formatted date string
  String get formattedDate {
    return '${auditTimestamp.month}/${auditTimestamp.day}/${auditTimestamp.year}';
  }

  /// Get formatted time string
  String get formattedTime {
    final hour = auditTimestamp.hour.toString().padLeft(2, '0');
    final minute = auditTimestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Represents a single recommendation
class Recommendation {
  final String criterion;
  final String recommendation;
  final String priority; // "High", "Medium", "Low"
  final double impactScore;

  Recommendation({
    required this.criterion,
    required this.recommendation,
    required this.priority,
    required this.impactScore,
  });

  /// Get color for priority level
  String getPriorityColor() {
    switch (priority) {
      case 'High':
        return 'red';
      case 'Medium':
        return 'orange';
      case 'Low':
        return 'green';
      default:
        return 'grey';
    }
  }

  /// Parse from JSON
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      criterion: json['criterion'] as String? ?? 'General',
      recommendation: json['recommendation'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      impactScore: (json['impact_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'criterion': criterion,
      'recommendation': recommendation,
      'priority': priority,
      'impact_score': impactScore,
    };
  }
}
