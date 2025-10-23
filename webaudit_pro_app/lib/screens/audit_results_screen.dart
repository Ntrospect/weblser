import 'package:flutter/material.dart';
import '../models/audit_result.dart';
import '../theme/spacing.dart';
import '../theme/button_styles.dart';
import '../widgets/styled_card.dart';
import '../widgets/app_badge.dart';
import 'audit_reports_screen.dart';
import 'criterion_detail_screen.dart';

class AuditResultsScreen extends StatefulWidget {
  final AuditResult auditResult;

  const AuditResultsScreen({
    Key? key,
    required this.auditResult,
  }) : super(key: key);

  @override
  State<AuditResultsScreen> createState() => _AuditResultsScreenState();
}

class _AuditResultsScreenState extends State<AuditResultsScreen> {
  late AuditResult _auditResult;
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    _auditResult = widget.auditResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Results'),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Image.asset(
              'assets/websler_pro.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.horizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Website Info
              _buildWebsiteInfo(context),
              const SizedBox(height: AppSpacing.sectionGap),

              // Overall Score Display
              _buildOverallScoreDisplay(context),
              const SizedBox(height: AppSpacing.sectionGap),

              // 10 Criterion Scores Grid
              _buildScoresGrid(context),
              const SizedBox(height: AppSpacing.sectionGap),

              // Key Strengths
              _buildSection(
                context,
                'Key Strengths',
                Icons.check_circle_outline,
                Colors.green,
                _auditResult.keyStrengths,
              ),
              const SizedBox(height: AppSpacing.componentGap),

              // Critical Issues
              _buildSection(
                context,
                'Critical Issues',
                Icons.warning_outlined,
                Colors.red,
                _auditResult.criticalIssues,
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // Priority Recommendations
              _buildRecommendationsSection(context),
              const SizedBox(height: AppSpacing.sectionGap),

              // View Reports Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToReports(),
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text(
                    'View Reports & Download PDFs',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: AppButtonStyles.primaryElevatedButton(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebsiteInfo(BuildContext context) {
    return StyledCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Website',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _auditResult.websiteName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.componentGap),
          Text(
            'Audit Date',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${_auditResult.formattedDate} at ${_auditResult.formattedTime}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScoreDisplay(BuildContext context) {
    final score = _auditResult.overallScore;
    late Color scoreColor, gradientColor;
    late String scoreStatus;

    if (score >= 7.5) {
      scoreColor = Colors.green;
      gradientColor = Colors.green.shade700;
      scoreStatus = 'Excellent';
    } else if (score >= 5.0) {
      scoreColor = Colors.orange;
      gradientColor = Colors.orange.shade700;
      scoreStatus = 'Good';
    } else {
      scoreColor = Colors.red;
      gradientColor = Colors.red.shade700;
      scoreStatus = 'Needs Work';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scoreColor, gradientColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Overall Score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${score.toStringAsFixed(1)}/10',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scoreStatus,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.95),
                  letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '10-Point Evaluation',
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
          itemCount: _auditResult.scores.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final entries = _auditResult.scores.entries.toList();
            final criterion = entries[index].key;
            final score = entries[index].value;
            return _buildScoreCard(context, criterion, score);
          },
        ),
      ],
    );
  }

  Widget _buildScoreCard(BuildContext context, String criterion, double score) {
    late Color bgColor, textColor, gradientColor;

    if (score >= 8) {
      bgColor = Colors.green.withOpacity(0.08);
      textColor = Colors.green;
      gradientColor = Colors.green.shade600;
    } else if (score >= 6) {
      bgColor = Colors.orange.withOpacity(0.08);
      textColor = Colors.orange;
      gradientColor = Colors.orange.shade600;
    } else {
      bgColor = Colors.red.withOpacity(0.08);
      textColor = Colors.red;
      gradientColor = Colors.red.shade600;
    }

    return _ScoreCardWithHover(
      criterion: criterion,
      score: score,
      bgColor: bgColor,
      textColor: textColor,
      gradientColor: gradientColor,
      onTap: () => _navigateToCriterionDetail(context, criterion, score),
    );
  }

  void _navigateToCriterionDetail(BuildContext context, String criterion, double score) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriterionDetailScreen(
          criterion: criterion,
          score: score,
          overallScore: _auditResult.overallScore,
          recommendations: _auditResult.priorityRecommendations,
          allScores: _auditResult.scores,
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.componentGap),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    final recommendations = _auditResult.priorityRecommendations.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Top Recommendations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.blue,
                      letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.componentGap),
        ...List.generate(
          recommendations.length,
          (index) {
            final rec = recommendations[index];
            final isExpanded = _expandedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                margin: EdgeInsets.zero,
                child: ExpansionTile(
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedIndex = expanded ? index : -1;
                    });
                  },
                  initiallyExpanded: isExpanded,
                  title: Text(
                    '${index + 1}. ${rec.criterion}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: !isExpanded ? Text(
                    rec.recommendation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ) : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.recommendation,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.componentGap),
                          PriorityBadge(priority: rec.priority),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _navigateToReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuditReportsScreen(
          auditResult: _auditResult,
        ),
      ),
    );
  }
}

/// Score card with interactive hover state
class _ScoreCardWithHover extends StatefulWidget {
  final String criterion;
  final double score;
  final Color bgColor;
  final Color textColor;
  final Color gradientColor;
  final VoidCallback onTap;

  const _ScoreCardWithHover({
    required this.criterion,
    required this.score,
    required this.bgColor,
    required this.textColor,
    required this.gradientColor,
    required this.onTap,
  });

  @override
  State<_ScoreCardWithHover> createState() => _ScoreCardWithHoverState();
}

class _ScoreCardWithHoverState extends State<_ScoreCardWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4 : 0.0),
        decoration: BoxDecoration(
          gradient: _isHovered
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.bgColor,
                    widget.bgColor.withOpacity(0.5),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.bgColor, widget.bgColor],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.textColor.withOpacity(_isHovered ? 0.5 : 0.2),
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.textColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: widget.textColor.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.score.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: widget.textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.criterion,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: widget.textColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: widget.textColor,
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
