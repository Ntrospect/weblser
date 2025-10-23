import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../models/analysis.dart';
import '../services/api_service.dart';
import '../theme/dark_theme.dart';

class ResultsScreen extends StatefulWidget {
  final Analysis analysis;

  const ResultsScreen({Key? key, required this.analysis}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isGeneratingPdf = false;
  String? _pdfError;
  String? _pdfFilePath;
  late ScrollController _scrollController;
  bool _isScrolled = false;

  void _generatePdf() async {
    setState(() {
      _isGeneratingPdf = true;
      _pdfError = null;
      _pdfFilePath = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final filePath = await apiService.generatePdf(widget.analysis.id);

      setState(() {
        _pdfFilePath = filePath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to Downloads!'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => _openPdfFile(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _pdfError = e.toString().replaceFirst('Exception: ', '');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_pdfError')),
        );
      }
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  void _openPdfFile(String filePath) async {
    try {
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open PDF: $e')),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMetadataField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => _copyToClipboard(value),
              tooltip: 'Copy',
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Analysis Result'),
        elevation: 0,
        backgroundColor: _isScrolled
            ? Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8)
            : Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
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
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 104.0, 24.0, 24.0),
          child: isDesktop ? _buildDesktopLayout(context, dateFormat) : _buildMobileLayout(context, dateFormat),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DateFormat dateFormat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Metadata
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // URL
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildMetadataField(context, 'URL', widget.analysis.url),
                ),
              ),
              const SizedBox(height: 16),

              // Page Title
              if (widget.analysis.title != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildMetadataField(context, 'Page Title', widget.analysis.title!),
                  ),
                ),
              if (widget.analysis.title != null) const SizedBox(height: 16),

              // Meta Description
              if (widget.analysis.metaDescription != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildMetadataField(context, 'Meta Description', widget.analysis.metaDescription!),
                  ),
                ),
              if (widget.analysis.metaDescription != null) const SizedBox(height: 16),

              // Timestamp
              Text(
                'Analyzed on ${dateFormat.format(widget.analysis.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Right Column - Summary
        Expanded(
          flex: 1,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: Theme.of(context).dividerColor,
                    height: 16,
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    widget.analysis.summary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isGeneratingPdf ? null : _generatePdf,
                          icon: _isGeneratingPdf
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                              : const Icon(Icons.file_download),
                          label: Text(_isGeneratingPdf ? 'Generating...' : 'Download PDF'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue.shade300
                                : Theme.of(context).primaryColor.withOpacity(0.8),
                            side: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.blue.shade300
                                  : Theme.of(context).primaryColor.withOpacity(0.8),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // URL
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMetadataField(context, 'URL', widget.analysis.url),
          ),
        ),
        const SizedBox(height: 16),

        // Page Title
        if (widget.analysis.title != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMetadataField(context, 'Page Title', widget.analysis.title!),
            ),
          ),
        if (widget.analysis.title != null) const SizedBox(height: 16),

        // Meta Description
        if (widget.analysis.metaDescription != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMetadataField(context, 'Meta Description', widget.analysis.metaDescription!),
            ),
          ),
        if (widget.analysis.metaDescription != null) const SizedBox(height: 16),

        // Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  color: Theme.of(context).dividerColor,
                  height: 12,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  widget.analysis.summary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Timestamp
        Text(
          'Analyzed on ${dateFormat.format(widget.analysis.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _isGeneratingPdf ? null : _generatePdf,
                icon: _isGeneratingPdf
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
                    : const Icon(Icons.file_download),
                label: Text(_isGeneratingPdf ? 'Generating...' : 'Download PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    foregroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue.shade300
                        : Theme.of(context).primaryColor.withOpacity(0.8),
                    side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue.shade300
                          : Theme.of(context).primaryColor.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
