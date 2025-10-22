import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/audit_result.dart';

class CriterionDetailScreen extends StatefulWidget {
  final String criterion;
  final double score;
  final double overallScore;
  final List<Recommendation> recommendations;
  final Map<String, double> allScores;

  const CriterionDetailScreen({
    Key? key,
    required this.criterion,
    required this.score,
    required this.overallScore,
    required this.recommendations,
    required this.allScores,
  }) : super(key: key);

  @override
  State<CriterionDetailScreen> createState() => _CriterionDetailScreenState();
}

class _CriterionDetailScreenState extends State<CriterionDetailScreen> {
  late List<Recommendation> _criterionRecommendations;

  @override
  void initState() {
    super.initState();
    _criterionRecommendations = widget.recommendations
        .where((rec) => rec.criterion == widget.criterion)
        .toList();
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 8) return 'Excellent';
    if (score >= 6) return 'Good';
    if (score >= 4) return 'Fair';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(widget.score);
    final scoreLabel = _getScoreLabel(widget.score);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.criterion),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score Display with Circular Gauge
              _buildScoreDisplay(color, scoreLabel),
              const SizedBox(height: 28),

              // Comparison Chart
              _buildComparisonChart(color),
              const SizedBox(height: 28),

              // Recommendations Section
              if (_criterionRecommendations.isNotEmpty) ...[
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ..._criterionRecommendations.map((rec) => _buildRecommendationCard(context, rec)),
                const SizedBox(height: 40),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No specific recommendations for this criterion. Great job!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: Column(
          children: [
          // Circular gauge using PieChart
          SizedBox(
            height: 200,
            width: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: widget.score,
                    color: color,
                    radius: 80,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 10 - widget.score,
                    color: color.withOpacity(0.2),
                    radius: 80,
                    showTitle: false,
                  ),
                ],
                centerSpaceRadius: 60,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            '${widget.score.toStringAsFixed(1)}/10',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildComparisonChart(Color color) {
    // Sort all scores by value for the chart
    final sortedScores = widget.allScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparison with Other Criteria',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: (sortedScores.length * 40.0) + 40,
              child: BarChart(
                BarChartData(
                  maxX: 10,
                  barDirection: BarDirection.horizontal,
                  barGroups: List.generate(
                    sortedScores.length,
                    (index) {
                      final entry = sortedScores[index];
                      final isCurrentCriterion = entry.key == widget.criterion;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toX: entry.value,
                            color: isCurrentCriterion ? color : Colors.blue.withOpacity(0.6),
                            width: 24,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 140,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedScores.length) {
                            final criterion = sortedScores[index].key;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                criterion,
                                style: Theme.of(context).textTheme.labelSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    verticalInterval: 2,
                    drawHorizontalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.criterion,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 24),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Other Criteria',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, Recommendation rec) {
    final priorityColor = _getPriorityColor(rec.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Priority: ${rec.priority}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: priorityColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Recommendation text
            Text(
              rec.recommendation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            // Impact score
            Row(
              children: [
                Icon(Icons.trending_up, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Impact Score: ${rec.impactScore.toStringAsFixed(1)}/10',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
