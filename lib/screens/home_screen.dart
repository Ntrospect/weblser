import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/analysis.dart';
import '../theme/dark_theme.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _urlController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _analyzeUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _error = 'Please enter a URL';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final analysis = await apiService.analyzeUrl(url);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(analysis: analysis),
          ),
        );
        _urlController.clear();
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyze a Website',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: 'Enter website URL (https://example.com)',
                        prefixIcon: const Icon(Icons.language),
                        suffixIcon: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _analyzeUrl(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DarkAppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: DarkAppTheme.errorColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: DarkAppTheme.errorColor, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: DarkAppTheme.errorColor,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _analyzeUrl,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.search, size: 28),
                        label: Text(
                          _isLoading ? 'Analyzing...' : 'Analyze',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // How It Works Section with Placeholder
            _buildHowItWorksSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final gridWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildStatsGrid(context),
      ],
    );

    final placeholderWidget = Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade300
                  : Theme.of(context).primaryColor.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Risk it for the Biscuit!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Fortune favors the hungry; leap first, learn fast, keep swinging until the crumbs turn into whole cakes today.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 75,
              height: 75,
              child: Image.asset(
                'assets/jumoki_AI_robot_gradient.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: gridWidget,
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 360,
              child: placeholderWidget,
            ),
          ),
        ],
      );
    } else {
      // Mobile layout - stack vertically
      return Column(
        children: [
          gridWidget,
          const SizedBox(height: 20),
          placeholderWidget,
        ],
      );
    }
  }

  Widget _buildStatsGrid(BuildContext context) {
    final steps = [
      ('1', '🔗', 'Input', 'Enter any website URL'),
      ('2', '⚙️', 'Process', 'AI extracts & analyzes'),
      ('3', '✨', 'Generate', 'Get intelligent summary'),
      ('4', '📥', 'Export', 'Download as PDF'),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final columns = isDesktop ? 2 : 1;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 140,
      ),
      itemCount: steps.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final step = steps[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number - fixed width
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: SizedBox(
                    width: 55,
                    child: Text(
                      step.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 79,
                        height: 1.0,
                        color: Color(0xFFB9C2D0),
                      ),
                    ),
                  ),
                ),
                // Title and description centered
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        step.$3,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2E68DA),
                        ),
                      ),
                      const SizedBox(height: 13),
                      Expanded(
                        child: Text(
                          step.$4,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
