import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/theme_provider.dart';
import '../models/website_analysis.dart';
import '../models/compliance_audit.dart';
import '../theme/spacing.dart';
import '../widgets/styled_card.dart';
import 'audit_results_screen.dart';
import 'compliance/compliance_report_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = false;
  bool _isScrolled = false;
  List<WebsiteAnalysis> _history = [];
  List<ComplianceAudit> _complianceHistory = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 10) {
      if (!_isScrolled) {
        setState(() => _isScrolled = true);
      }
    } else {
      if (_isScrolled) {
        setState(() => _isScrolled = false);
      }
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<ApiService>();

      // Load both summaries/audits and compliance audits
      final unifiedHistory = await apiService.getUnifiedHistory(limit: 50);
      final complianceAudits = await apiService.getComplianceHistory(limit: 50);

      if (mounted) {
        setState(() {
          _history = unifiedHistory;
          _complianceHistory = complianceAudits;
        });
      }
    } catch (e) {
      if (mounted) {
        // Only show error if it's not a connection error (backend not running)
        // Connection errors are expected when backend is not running - just show empty state
        final errorStr = e.toString().toLowerCase();
        if (!errorStr.contains('refused') && !errorStr.contains('connection') && !errorStr.contains('localhost')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading history: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _history = [];
          _complianceHistory = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _deleteAnalysis(WebsiteAnalysis analysis) async {
    try {
      await context.read<ApiService>().deleteAnalysisUnified(analysis);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analysis deleted')),
        );
        _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteCompliance(ComplianceAudit compliance) async {
    try {
      await context.read<ApiService>().deleteComplianceAudit(compliance.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compliance audit deleted')),
        );
        _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _upgradeToAudit(WebsiteAnalysis summary) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Running WebAudit Pro...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take 1 to 3 minutes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );

    try {
      final apiService = context.read<ApiService>();
      final auditResult = await apiService.upgradeToAudit(summary);

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Navigate to audit results
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AuditResultsScreen(auditResult: auditResult.auditResult!),
          ),
        ).then((_) {
          _loadHistory();
        });
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewAudit(WebsiteAnalysis analysis) {
    if (analysis.isAudit && analysis.auditResult != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AuditResultsScreen(auditResult: analysis.auditResult!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final bgColor = themeProvider.isDarkMode
            ? const Color(0xFF0F1419)
            : Colors.white;
        final scrolledBgColor = themeProvider.isDarkMode
            ? const Color(0xFF0F1419).withOpacity(0.95)
            : Colors.white.withOpacity(0.8);

        return Consumer<AuthService>(
          builder: (context, authService, _) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Analysis History'),
                    if (authService.currentUser != null)
                      Text(
                        authService.currentUser!.email,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                  ],
                ),
                titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                elevation: 0,
                backgroundColor: _isScrolled ? scrolledBgColor : bgColor,
                surfaceTintColor: bgColor,
          ),
          body: RefreshIndicator(
            onRefresh: _loadHistory,
            child: _isLoading && _history.isEmpty && _complianceHistory.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty && _complianceHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No analyses yet',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start by analyzing a website on the Home tab',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 130, 16, 16),
                        itemCount: _history.length + _complianceHistory.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          // Display summaries/audits first, then compliance audits
                          if (index < _history.length) {
                            final analysis = _history[index];
                            return _buildHistoryCard(analysis);
                          } else {
                            final complianceIndex = index - _history.length;
                            final compliance = _complianceHistory[complianceIndex];
                            return _buildComplianceCard(compliance);
                          }
                        },
                      ),
          ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(WebsiteAnalysis analysis) {
    final color = analysis.isSummary
        ? Colors.blue
        : (analysis.auditResult?.overallScore ?? 0) >= 7.5
            ? Colors.green
            : (analysis.auditResult?.overallScore ?? 0) >= 5
                ? Colors.orange
                : Colors.red;

    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  analysis.isSummary ? Icons.summarize : Icons.assessment,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Raleway',
                            fontSize: 18,
                          ),
                    ),
                    Text(
                      analysis.formattedDateTime,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (analysis.isAudit && analysis.overallScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${analysis.overallScore!.toStringAsFixed(1)}/10',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // URL
          Text(
            'URL',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SelectableText(
            analysis.url,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          // Summary
          Text(
            analysis.isSummary ? 'Summary' : 'Overall Result',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            analysis.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (analysis.isSummary)
                OutlinedButton(
                  onPressed: () => _upgradeToAudit(analysis),
                  child: const Text('Upgrade to Pro'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _viewAudit(analysis),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View Audit'),
                ),
              const SizedBox(width: AppSpacing.sm),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteAnalysis(analysis);
                  }
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ],
        ),
      );
  }

  Widget _buildComplianceCard(ComplianceAudit compliance) {
    final scoreColor = compliance.overallScore >= 80
        ? Colors.green
        : compliance.overallScore >= 60
            ? Colors.orange
            : Colors.red;

    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.gavel,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compliance Report',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      compliance.url,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${compliance.overallScore}/100',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Jurisdictions
          Wrap(
            spacing: 8,
            children: compliance.jurisdictions.map((jurisdiction) {
              return Chip(
                label: Text(
                  '${ComplianceAudit.getJurisdictionEmoji(jurisdiction)} ${ComplianceAudit.getJurisdictionName(jurisdiction)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                side: BorderSide(color: Colors.grey[300]!),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Date and Risk Level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                compliance.createdAt.split('T')[0],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  compliance.highestRiskLevel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _deleteCompliance(compliance),
                child: const Text('Delete'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComplianceReportScreen(
                        compliance: compliance,
                      ),
                    ),
                  ).then((_) => _loadHistory());
                },
                child: const Text('View Report'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
