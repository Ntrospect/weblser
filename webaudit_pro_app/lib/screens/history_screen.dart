import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/theme_provider.dart';
import '../models/website_analysis.dart';
import '../theme/spacing.dart';
import '../widgets/styled_card.dart';
import 'audit_results_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = false;
  bool _isScrolled = false;
  List<WebsiteAnalysis> _history = [];
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
      final history = await apiService.getUnifiedHistory(limit: 50);
      if (mounted) {
        setState(() {
          _history = history;
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

  void _clearHistory() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all analyses? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Clear summaries first
                try {
                  await context.read<ApiService>().clearHistory();
                } catch (e) {
                  debugPrint('⚠️ Error clearing summaries: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error clearing summaries: $e'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }

                // Then clear audits
                try {
                  await context.read<ApiService>().clearAuditHistory();
                } catch (e) {
                  debugPrint('⚠️ Error clearing audits: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error clearing audits: $e'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }

                // Reload history
                if (mounted) {
                  debugPrint('🔄 Reloading history after delete...');
                  _loadHistory();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ History cleared successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                debugPrint('❌ Unexpected error in _clearHistory: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unexpected error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
            actions: [
              if (_history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Clear History',
                  onPressed: _clearHistory,
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadHistory,
            child: _isLoading && _history.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
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
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final analysis = _history[index];
                          return _buildHistoryCard(analysis);
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
}
