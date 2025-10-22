import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/audit_result.dart';
import '../theme/dark_theme.dart';
import '../theme/spacing.dart';
import '../widgets/styled_card.dart';
import 'audit_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _urlController;
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  String? _error;
  List<AuditResult> _recentAudits = [];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _loadAuditHistory();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadAuditHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final apiService = context.read<ApiService>();
      final audits = await apiService.getAuditHistory(limit: 10);
      if (mounted) {
        setState(() {
          _recentAudits = audits;
        });
      }
    } catch (e) {
      // Silently fail - audit history is optional
      if (mounted) {
        setState(() {
          _recentAudits = [];
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

  void _auditWebsite() async {
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
      final auditResult = await apiService.auditWebsite(url);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuditResultsScreen(auditResult: auditResult),
          ),
        ).then((_) {
          // Refresh audit history when returning
          _loadAuditHistory();
        });
        _urlController.clear();
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

  void _loadAuditFromHistory(AuditResult audit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuditResultsScreen(auditResult: audit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal,
          vertical: AppSpacing.vertical,
        ).copyWith(bottom: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audit Input Card
            _buildAuditInputCard(context),
            const SizedBox(height: AppSpacing.sectionGap),

            // Recent Audits Section
            if (_recentAudits.isNotEmpty) ...[
              _buildRecentAuditsSection(context),
              const SizedBox(height: AppSpacing.sectionGap),
            ],

            // How It Works Section
            _buildHowItWorksSection(context),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditInputCard(BuildContext context) {
    return ElevatedStyledCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Audit Your Website',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Get a professional 10-point evaluation of your digital presence',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
            ),
          ),
          const SizedBox(height: AppSpacing.componentGap),

          // URL Input Field
          TextField(
            controller: _urlController,
            enabled: !_isLoading,
            decoration: InputDecoration(
              hintText: 'Enter website URL (e.g., github.com)',
              prefixIcon: const Icon(Icons.language),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            onSubmitted: (_) => _auditWebsite(),
          ),

          // Error message
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Audit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _auditWebsite,
              icon: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.assessment_outlined, size: 22),
              label: Text(
                _isLoading ? 'Auditing Website...' : 'Start Audit',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAuditsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Audits',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            if (_recentAudits.length > 3)
              Text(
                'View all',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.componentGap),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_recentAudits.length > 3) ? 3 : _recentAudits.length,
          itemBuilder: (context, index) {
            final audit = _recentAudits[index];
            return _buildAuditHistoryCard(context, audit);
          },
        ),
      ],
    );
  }

  Widget _buildAuditHistoryCard(BuildContext context, AuditResult audit) {
    final scoreColor = _getScoreColor(audit.overallScore);

    return SubtleCard(
      padding: EdgeInsets.zero,
      onTap: () => _loadAuditFromHistory(audit),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audit.websiteName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    audit.formattedDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  '${audit.overallScore.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    final steps = [
      (
        '📋',
        'Input',
        'Enter any website URL',
      ),
      (
        '🔍',
        'Analyze',
        'Comprehensive 10-point audit',
      ),
      (
        '📊',
        'Results',
        'Detailed scores & recommendations',
      ),
      (
        '📥',
        'Export',
        'Download professional PDFs',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.componentGap),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: 140,
          ),
          itemCount: steps.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final step = steps[index];
            return SubtleCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    step.$1,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    step.$2,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    step.$3,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
