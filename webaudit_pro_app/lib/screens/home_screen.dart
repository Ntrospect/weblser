import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/website_analysis.dart';
import '../theme/spacing.dart';
import '../widgets/styled_card.dart';
import '../widgets/process_timeline.dart';
import 'audit_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TextEditingController _urlController;
  late TabController _tabController;

  bool _isLoading = false;
  bool _isLoadingHistory = false;
  String? _error;
  List<WebsiteAnalysis> _unifiedHistory = [];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final apiService = context.read<ApiService>();
      final history = await apiService.getUnifiedHistory(limit: 50);
      if (mounted) {
        setState(() {
          _unifiedHistory = history;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _unifiedHistory = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  void _generateSummary() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _error = 'Please enter a website URL';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final summary = await apiService.generateWebslerSummary(url);

      if (mounted) {
        // Show summary details in a dialog/sheet
        _showSummaryDialog(summary);
        _urlController.clear();
        // Refresh history
        _loadHistory();
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSummaryDialog(WebsiteAnalysis summary) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Summary Generated',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.md),

              // URL
              Text(
                'URL',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SelectableText(
                summary.url,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              if (summary.title != null) ...[
                Text(
                  'Title',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  summary.title!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Summary
              Text(
                'Summary',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                summary.summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _upgradeToAudit(summary);
                    },
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Upgrade to Pro Audit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _upgradeToAudit(WebsiteAnalysis summary) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<ApiService>();
      final auditResult = await apiService.upgradeToAudit(summary);

      if (mounted) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadAuditFromHistory(WebsiteAnalysis analysis) {
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
    return Column(
      children: [
        // Tab Bar
        Material(
          elevation: 2,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(
                icon: Icon(Icons.summarize),
                text: 'Websler',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'History',
              ),
            ],
          ),
        ),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Websler Tab - Summary Generation
              _buildWebslerTab(),
              // History Tab - Unified History with Upgrade
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebslerTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal,
          vertical: AppSpacing.vertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            // Summary Input Card
            _buildSummaryInputCard(context),
            const SizedBox(height: AppSpacing.sectionGap),

            // How It Works
            _buildHowItWorksSection(context),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_unifiedHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No analyses yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Generate a summary or run an audit to get started',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal,
        vertical: AppSpacing.vertical,
      ),
      itemCount: _unifiedHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final analysis = _unifiedHistory[index];
        return _buildHistoryCard(analysis);
      },
    );
  }

  Widget _buildSummaryInputCard(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      shadowColor: const Color(0xFF2E68DA).withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF2E68DA),
              Color(0xFF9018AD),
            ],
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analyze Your Website',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Get a quick AI-powered summary of any website',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
            ),
            const SizedBox(height: AppSpacing.componentGap),

            // URL Input
            TextField(
              controller: _urlController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Enter website URL (e.g., github.com)',
                prefixIcon: const Icon(Icons.language, color: Color(0xFF9018AD)),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
              onSubmitted: (_) => _generateSummary(),
            ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateSummary,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.summarize, size: 22),
                label: Text(
                  _isLoading ? 'Analyzing...' : 'Generate Summary',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E68DA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
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
          Text(
            analysis.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          // Summary
          Text(
            'Summary',
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
              if (analysis.isSummary) ...[
                OutlinedButton(
                  onPressed: () => _upgradeToAudit(analysis),
                  child: const Text('Upgrade to Pro'),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () => _loadAuditFromHistory(analysis),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View Audit'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        ProcessTimeline(
          steps: const [
            'Enter your website URL',
            'AI analyzes the content',
            'Get instant summary',
            'Optional: Upgrade to Pro Audit',
          ],
        ),
      ],
    );
  }
}
