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
    late Color scoreColor;
    late String scoreStatus;

    if (score >= 7.5) {
      scoreColor = Colors.green;
      scoreStatus = 'Excellent';
    } else if (score >= 5.0) {
      scoreColor = Colors.orange;
      scoreStatus = 'Good';
    } else {
      scoreColor = Colors.red;
      scoreStatus = 'Needs Work';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scoreColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Overall Score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${score.toStringAsFixed(1)}/10',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scoreStatus,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
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
    late Color bgColor, textColor;

    if (score >= 8) {
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
    } else if (score >= 6) {
      bgColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange;
    } else {
      bgColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red;
    }

    return GestureDetector(
      onTap: () => _navigateToCriterionDetail(context, criterion, score),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                criterion,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: textColor.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
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
            Icon(icon, color: color, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check_circle,
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
            const Icon(Icons.lightbulb_outline, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Top Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
