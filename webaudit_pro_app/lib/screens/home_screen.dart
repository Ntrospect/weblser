import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/audit_result.dart';
import '../theme/spacing.dart';
import '../theme/button_styles.dart';
import '../widgets/styled_card.dart';
import '../widgets/process_timeline.dart';
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
        ).copyWith(bottom: AppSpacing.xl, top: 88),
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
    return Material(
      elevation: 8,
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
          border: Border.all(
            color: const Color(0xFF2E68DA).withOpacity(0.3),
            width: 1,
          ),
        ),
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
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Get a professional 10-point evaluation of your digital presence',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: AppSpacing.componentGap),

          // URL Input Field
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
                borderRadius: BorderRadius.circular(AppRadius.small),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              hintStyle: const TextStyle(color: Colors.grey),
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
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_recentAudits.length > 3) ? 3 : _recentAudits.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
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

    return _AuditHistoryCardWithHover(
      audit: audit,
      scoreColor: scoreColor,
      onTap: () => _loadAuditFromHistory(audit),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 7.5) return Colors.green;
    if (score >= 5.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return const ProcessTimeline();
  }
}

/// Audit history card with hover state
class _AuditHistoryCardWithHover extends StatefulWidget {
  final AuditResult audit;
  final Color scoreColor;
  final VoidCallback onTap;

  const _AuditHistoryCardWithHover({
    required this.audit,
    required this.scoreColor,
    required this.onTap,
  });

  @override
  State<_AuditHistoryCardWithHover> createState() =>
      _AuditHistoryCardWithHoverState();
}

class _AuditHistoryCardWithHoverState extends State<_AuditHistoryCardWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.35),
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: _isHovered ? Colors.grey.withOpacity(0.02) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.audit.websiteName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.audit.formattedDate,
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
                      color: widget.scoreColor,
                    ),
                    child: Transform.translate(
                      offset: const Offset(0, 2),
                      child: Center(
                        child: Text(
                          '${widget.audit.overallScore.toStringAsFixed(1)}',
                          style: GoogleFonts.leagueSpartan(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
