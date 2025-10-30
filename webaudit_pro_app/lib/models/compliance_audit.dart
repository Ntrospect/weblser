/// Represents a single compliance finding within a category
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

  factory ComplianceFinding.fromJson(Map<String, dynamic> json) {
    return ComplianceFinding(
      category: json['category'] as String,
      status: json['status'] as String,
      riskLevel: json['risk_level'] as String,
      findings: List<String>.from(json['findings'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
      priority: json['priority'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'status': status,
    'risk_level': riskLevel,
    'findings': findings,
    'recommendations': recommendations,
    'priority': priority,
  };
}

/// Represents compliance scores and findings for a single jurisdiction
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

  factory ComplianceJurisdictionScore.fromJson(Map<String, dynamic> json) {
    return ComplianceJurisdictionScore(
      jurisdiction: json['jurisdiction'] as String,
      score: json['score'] as int,
      findings: (json['findings'] as List)
          .map((f) => ComplianceFinding.fromJson(f as Map<String, dynamic>))
          .toList(),
      criticalIssues: List<String>.from(json['critical_issues'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
    'jurisdiction': jurisdiction,
    'score': score,
    'findings': findings.map((f) => f.toJson()).toList(),
    'critical_issues': criticalIssues,
  };
}

/// Complete compliance audit report
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
  final String highestRiskLevel;

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
    this.highestRiskLevel = 'High',
  });

  factory ComplianceAudit.fromJson(Map<String, dynamic> json) {
    return ComplianceAudit(
      id: json['id'] as String,
      url: json['url'] as String,
      siteTitle: json['site_title'] as String?,
      jurisdictions: List<String>.from(json['jurisdictions'] as List),
      overallScore: json['overall_score'] as int,
      jurisdictionScores: (json['jurisdiction_scores'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
              key,
              ComplianceJurisdictionScore.fromJson(
                  value as Map<String, dynamic>))),
      criticalIssues: List<String>.from(json['critical_issues'] as List),
      remediationRoadmap: json['remediation_roadmap'] as Map<String, dynamic>,
      createdAt: json['created_at'] as String,
      highestRiskLevel: json['highest_risk_level'] as String? ?? 'High',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'site_title': siteTitle,
    'jurisdictions': jurisdictions,
    'overall_score': overallScore,
    'jurisdiction_scores': jurisdictionScores
        .map((key, value) => MapEntry(key, value.toJson())),
    'critical_issues': criticalIssues,
    'remediation_roadmap': remediationRoadmap,
    'created_at': createdAt,
    'highest_risk_level': highestRiskLevel,
  };

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
