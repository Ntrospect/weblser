import 'package:flutter/material.dart';
import '../theme/spacing.dart';

/// Animated process timeline showing workflow steps
class ProcessTimeline extends StatefulWidget {
  final List<String>? steps; // Optional custom steps (if null, uses default audit steps)

  const ProcessTimeline({Key? key, this.steps}) : super(key: key);

  @override
  State<ProcessTimeline> createState() => _ProcessTimelineState();
}

class _ProcessTimelineState extends State<ProcessTimeline>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use custom steps if provided, otherwise use default audit workflow
    final stepsList = widget.steps ?? [
      'Enter your website URL',
      'AI analyzes the content',
      'Get instant summary',
      'Optional: Upgrade to Pro Audit',
    ];

    // Convert to structured format for timeline
    final structuredSteps = _buildStepStructure(stepsList);

    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SizedBox(height: 20),
        isDesktop
            ? _buildHorizontalTimeline(context, structuredSteps)
            : _buildVerticalTimeline(context, structuredSteps),
      ],
    );
  }

  Widget _buildHorizontalTimeline(BuildContext context, List<dynamic> steps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (index) {
        final isConnector = index.isOdd;

        if (isConnector) {
          // Connector line
          final connectorIndex = index ~/ 2;
          return SizedBox(
            width: 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                _buildAnimatedConnector(connectorIndex),
              ],
            ),
          );
        } else {
          // Step circle
          final stepIndex = index ~/ 2;
          final step = steps[stepIndex];

          return SizedBox(
            height: 155,
            child: Column(
              children: [
                _buildStepCircle(
                  context,
                  step.icon,
                  stepIndex + 1,
                  stepIndex,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _buildVerticalTimeline(BuildContext context, List<dynamic> steps) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column with circle and connector
                Column(
                  children: [
                    _buildStepCircle(
                      context,
                      step.icon,
                      index + 1,
                      index,
                    ),
                    // Vertical connector (skip for last item)
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor
                                  .withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.lg),
                // Right column with text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).primaryColor,
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          step.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!isLast) const SizedBox(height: AppSpacing.componentGap),
          ],
        );
      }),
    );
  }

  Widget _buildStepCircle(
    BuildContext context,
    IconData icon,
    int stepNumber,
    int index,
  ) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor.withOpacity(0.1),
        border: Border.all(
          color: primaryColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: primaryColor,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildAnimatedConnector(int stepIndex) {
    return AnimatedBuilder(
      animation: _lineAnimation,
      builder: (context, child) {
        // Calculate when this specific line should animate
        final lineStartTime = (stepIndex / 3.0);
        final lineEndTime = ((stepIndex + 1) / 3.0);

        final lineProgress = (_lineAnimation.value - lineStartTime) /
            (lineEndTime - lineStartTime);
        final clampedProgress = lineProgress.clamp(0.0, 1.0);

        return Row(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background line
                  Container(
                    height: 2,
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                  // Animated progress line
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: clampedProgress,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor
                                  .withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Convert string steps to structured step data with icons
  List<dynamic> _buildStepStructure(List<String> stepsList) {
    final icons = [
      Icons.description_outlined,
      Icons.analytics_outlined,
      Icons.assessment_outlined,
      Icons.download_outlined,
      Icons.check_circle_outlined,
    ];

    return List.generate(
      stepsList.length,
      (index) => (
        icon: index < icons.length ? icons[index] : Icons.check_circle_outlined,
        title: 'Step ${index + 1}',
        description: stepsList[index],
      ),
    );
  }
}
