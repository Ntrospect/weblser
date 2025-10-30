import 'package:json_annotation/json_annotation.dart';

part 'compliance_audit.g.dart';

/// Represents a single compliance finding within a category
@JsonSerializable()
class ComplianceFinding {
  final String category;
  final String status; // Compliant, Partially Compliant, Non-Compliant
  final String riskLevel; // Critical, High, Medium, Low
  final List<String> findings;
  final List<String> recommendations;
  final String priority; // Immediate, Short-term, Long-term

  ComplianceFinding({
    required this.category,
    required this.status,
    required this.riskLevel,
    required this.findings,
    required this.recommendations,
    required this.priority,
  });

  factory ComplianceFinding.fromJson(Map<String, dynamic> json) =>
      _$ComplianceFindingFromJson(json);

  Map<String, dynamic> toJson() => _$ComplianceFindingToJson(this);
}

/// Represents compliance scores and findings for a single jurisdiction
@JsonSerializable()
class ComplianceJurisdictionScore {
  final String jurisdiction; // AU, NZ, GDPR, CCPA
  final int score;
  final List<ComplianceFinding> findings;
  final List<String> criticalIssues;

  ComplianceJurisdictionScore({
    required this.jurisdiction,
    required this.score,
    required this.findings,
    required this.criticalIssues,
  });

  factory ComplianceJurisdictionScore.fromJson(Map<String, dynamic> json) =>
      _$ComplianceJurisdictionScoreFromJson(json);

  Map<String, dynamic> toJson() => _$ComplianceJurisdictionScoreToJson(this);
}

/// Complete compliance audit report
@JsonSerializable()
class ComplianceAudit {
  final String id;
  final String url;
  final String? siteTitle;
  final List<String> jurisdictions;
  final int overallScore;
  final Map<String, ComplianceJurisdictionScore> jurisdictionScores;
  final List<String> criticalIssues;
  final Map<String, dynamic> remediationRoadmap;
  final String createdAt;

  ComplianceAudit({
    required this.id,
    required this.url,
    this.siteTitle,
    required this.jurisdictions,
    required this.overallScore,
    required this.jurisdictionScores,
    required this.criticalIssues,
    required this.remediationRoadmap,
    required this.createdAt,
  });

  factory ComplianceAudit.fromJson(Map<String, dynamic> json) =>
      _$ComplianceAuditFromJson(json);

  Map<String, dynamic> toJson() => _$ComplianceAuditToJson(this);

  /// Get human-readable jurisdiction name
  static String getJurisdictionName(String code) {
    switch (code) {
      case 'AU':
        return 'Australia';
      case 'NZ':
        return 'New Zealand';
      case 'GDPR':
        return 'GDPR (EU)';
      case 'CCPA':
        return 'CCPA (California)';
      default:
        return code;
    }
  }

  /// Get emoji/icon for jurisdiction
  static String getJurisdictionEmoji(String code) {
    switch (code) {
      case 'AU':
        return '🇦🇺';
      case 'NZ':
        return '🇳🇿';
      case 'GDPR':
        return '🇪🇺';
      case 'CCPA':
        return '🇺🇸';
      default:
        return '⚖️';
    }
  }

  /// Get color for risk level
  static String getRiskLevelColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'critical':
        return '#DC2626'; // Red-600
      case 'high':
        return '#EA580C'; // Orange-600
      case 'medium':
        return '#FBBF24'; // Amber-400
      case 'low':
        return '#22C55E'; // Green-500
      default:
        return '#6B7280'; // Gray-500
    }
  }

  /// Get compliance status color
  static String getStatusColor(String status) {
    switch (status) {
      case 'Compliant':
        return '#10B981'; // Emerald-500
      case 'Partially Compliant':
        return '#F59E0B'; // Amber-500
      case 'Non-Compliant':
        return '#EF4444'; // Red-500
      default:
        return '#6B7280'; // Gray-500
    }
  }

  /// Get priority order for sorting
  static int getPriorityOrder(String priority) {
    switch (priority) {
      case 'Immediate':
        return 0;
      case 'Short-term':
        return 1;
      case 'Long-term':
        return 2;
      default:
        return 3;
    }
  }
}

/// Request model for creating a compliance audit
class ComplianceAuditRequest {
  final String url;
  final List<String> jurisdictions;
  final int timeout;
  final String? auditId; // Optional: link to existing audit

  ComplianceAuditRequest({
    required this.url,
    required this.jurisdictions,
    this.timeout = 10,
    this.auditId,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'jurisdictions': jurisdictions,
    'timeout': timeout,
    'audit_id': auditId,
  };
}

/// Helper enum for compliance statuses
enum ComplianceStatus {
  compliant,
  partiallyCompliant,
  nonCompliant;

  String get displayName {
    switch (this) {
      case ComplianceStatus.compliant:
        return 'Compliant';
      case ComplianceStatus.partiallyCompliant:
        return 'Partially Compliant';
      case ComplianceStatus.nonCompliant:
        return 'Non-Compliant';
    }
  }
}

/// Helper enum for risk levels
enum RiskLevel {
  critical,
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case RiskLevel.critical:
        return 'Critical';
      case RiskLevel.high:
        return 'High';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.low:
        return 'Low';
    }
  }

  String get emoji {
    switch (this) {
      case RiskLevel.critical:
        return '🔴';
      case RiskLevel.high:
        return '🟠';
      case RiskLevel.medium:
        return '🟡';
      case RiskLevel.low:
        return '🟢';
    }
  }
}

/// Helper enum for priority levels
enum Priority {
  immediate,
  shortTerm,
  longTerm;

  String get displayName {
    switch (this) {
      case Priority.immediate:
        return 'Immediate (0-30 days)';
      case Priority.shortTerm:
        return 'Short-term (1-3 months)';
      case Priority.longTerm:
        return 'Long-term (3-6 months)';
    }
  }

  String get emoji {
    switch (this) {
      case Priority.immediate:
        return '⚡';
      case Priority.shortTerm:
        return '📅';
      case Priority.longTerm:
        return '🔮';
    }
  }
}
