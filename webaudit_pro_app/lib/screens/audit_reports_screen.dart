import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audit_result.dart';
import '../services/api_service.dart';
import 'dart:io';

class AuditReportsScreen extends StatefulWidget {
  final AuditResult auditResult;

  const AuditReportsScreen({
    Key? key,
    required this.auditResult,
  }) : super(key: key);

  @override
  State<AuditReportsScreen> createState() => _AuditReportsScreenState();
}

class _AuditReportsScreenState extends State<AuditReportsScreen> {
  late AuditResult _auditResult;
  String? _generatingPdf; // Track which PDF is being generated (null, "audit-report", etc.)
  String? _downloadedPath; // Store path of last downloaded PDF
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _auditResult = widget.auditResult;
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

  Future<void> _downloadPdf(String documentType, String documentName) async {
    setState(() {
      _generatingPdf = documentType;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final companyName = prefs.getString('pdf_company_name') ?? 'WebAudit Pro';
      final companyDetails = prefs.getString('pdf_company_details');

      final apiService = context.read<ApiService>();
      final filepath = await apiService.generateAuditPdf(
        _auditResult.id,
        documentType,
        clientName: _auditResult.websiteName,
        companyName: companyName,
        companyDetails: companyDetails,
      );

      if (mounted) {
        setState(() {
          _downloadedPath = filepath;
          _generatingPdf = null;
        });

        // Show success snackbar with "Open PDF" button
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$documentName downloaded successfully'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OPEN',
              onPressed: () => _openPdf(filepath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generatingPdf = null;
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _openPdf(String filepath) {
    // For now, show a message that the file is ready
    // In a real app, you'd use url_launcher or similar to open the file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved to: $filepath'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Download Reports'),
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
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Website Header
              _buildWebsiteHeader(),
              const SizedBox(height: 28),

              // Report Cards Section
              _buildDocumentCard(
                icon: Icons.assessment_outlined,
                iconColor: Colors.blue,
                title: 'Website Audit Report',
                description: 'Diagnostic assessment',
                badge: 'FREE',
                badgeColor: Colors.green,
                bullets: [
                  '10-point website evaluation',
                  'Identified strengths & weaknesses',
                  'Executive summary of findings',
                ],
                documentType: 'audit-report',
                documentName: 'Audit Report',
              ),
              const SizedBox(height: 16),

              _buildDocumentCard(
                icon: Icons.trending_up_outlined,
                iconColor: Colors.orange,
                title: 'Website Improvement Plan',
                description: 'Strategic roadmap',
                badge: 'STRATEGIC',
                badgeColor: Colors.orange,
                bullets: [
                  'Priority recommendations ranked',
                  'Implementation timeline & steps',
                  'Expected outcomes & impact',
                ],
                documentType: 'improvement-plan',
                documentName: 'Improvement Plan',
              ),
              const SizedBox(height: 16),

              _buildDocumentCard(
                icon: Icons.handshake_outlined,
                iconColor: Colors.purple,
                title: 'Digital Partnership Proposal',
                description: 'Engagement package',
                badge: 'CONTRACT',
                badgeColor: Colors.purple,
                bullets: [
                  'Our approach & expertise',
                  'Scope of work & deliverables',
                  'Timeline, pricing & terms',
                ],
                documentType: 'partnership-proposal',
                documentName: 'Partnership Proposal',
              ),
              const SizedBox(height: 40),

              // Back Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Results'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebsiteHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Website',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _auditResult.websiteName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Audit ID',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _auditResult.id,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String badge,
    required Color badgeColor,
    required List<String> bullets,
    required String documentType,
    required String documentName,
  }) {
    final isGenerating = _generatingPdf == documentType;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and badge
            Row(
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bullet points
            ...bullets.map((bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bullet,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),

            // Download button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isGenerating ? null : () => _downloadPdf(documentType, documentName),
                icon: isGenerating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.file_download_outlined),
                label: Text(
                  isGenerating ? 'Generating PDF...' : 'Download PDF',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
