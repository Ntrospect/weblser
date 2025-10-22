import 'package:flutter/material.dart';
import '../theme/spacing.dart';

/// Animated process timeline showing the audit workflow
class ProcessTimeline extends StatefulWidget {
  const ProcessTimeline({Key? key}) : super(key: key);

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
    final steps = [
      (
        icon: Icons.description_outlined,
        title: 'Input',
        description: 'Enter website URL',
      ),
      (
        icon: Icons.analytics_outlined,
        title: 'Analyze',
        description: '10-point audit',
      ),
      (
        icon: Icons.assessment_outlined,
        title: 'Results',
        description: 'Detailed scores',
      ),
      (
        icon: Icons.download_outlined,
        title: 'Export',
        description: 'Download PDFs',
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
        const SizedBox(height: AppSpacing.lg),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 800
                  ? MediaQuery.of(context).size.width - AppSpacing.horizontal * 2
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(steps.length, (index) {
                  final step = steps[index];
                  final isLast = index == steps.length - 1;

                  return Expanded(
                    child: Row(
                      children: [
                        // Step circle
                        Expanded(
                          child: Column(
                            children: [
                              _buildStepCircle(
                                context,
                                step.icon,
                                index + 1,
                                index,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                step.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                step.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Connecting line (skip for last item)
                        if (!isLast)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 24),
                                _buildAnimatedConnector(index),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
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
                  // Arrow indicator at the end of animated line
                  if (clampedProgress > 0.5)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: Offset(
                          (MediaQuery.of(context).size.width * 0.15 *
                                  clampedProgress) -
                              8,
                          0,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).primaryColor,
                          size: 16,
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
}
