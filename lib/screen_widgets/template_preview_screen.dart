// lib/screens/template_preview_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import 'package:lanka_law/models/template_item.dart';
import 'package:provider/provider.dart';
import 'package:lanka_law/services/templates_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class TemplatePreviewScreen extends StatefulWidget {
  final TemplateItem template;

  const TemplatePreviewScreen({super.key, required this.template});

  @override
  State<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends State<TemplatePreviewScreen> {
  bool _isLoadingUrl = false;
  String? _signedUrl;

  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchSignedUrl();
  }

  Future<void> _fetchSignedUrl() async {
    setState(() => _isLoadingUrl = true);
    try {
      print(
        '[TemplatePreview] templateId=${widget.template.id} title=${widget.template.title}',
      );
      final url = await context.read<TemplatesProvider>().getSignedUrl(
        widget.template.id.toString(),
      );
      print('[TemplatePreview] signedUrl=$url');

      if (!mounted) return;
      setState(() {
        _signedUrl = url;
        _isLoadingUrl = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingUrl = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load document link: $e')),
      );
    }
  }

  Future<void> _launchUrlExternal(
    BuildContext context,
    String? urlString,
  ) async {
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL not available.')));
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }

  String _safeFilename(String title) {
    return title
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '')
        .replaceAll(' ', '_');
  }

  Future<void> _downloadAndOpenDoc(BuildContext context) async {
    if (_signedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL not available yet. Please wait.')),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();

      // ✅ correct extension (pdf/doc/docx)
      final ext = (widget.template.fileType ?? 'pdf').toLowerCase();
      final fileName =
          "${_safeFilename(widget.template.title)}_${widget.template.templateCode}.$ext";
      final savePath = "${dir.path}/$fileName";

      print(
        '[TemplatePreview] download started url=$_signedUrl savePath=$savePath',
      );

      await Dio().download(
        _signedUrl!,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      if (!mounted) return;
      setState(() => _isDownloading = false);

      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  void _openPdfViewer(BuildContext context) {
    if (_signedUrl == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(widget.template.title),
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SfPdfViewer.network(_signedUrl!),
        ),
      ),
    );
  }

  Color _getColor() {
    switch (widget.template.mainCategory) {
      case "Business":
        return Colors.indigo;
      case "Real Estate":
        return Colors.teal;
      case "Personal":
        return Colors.orange;
      case "Legal":
        return Colors.purple;
      case "HR":
        return Colors.blue;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getIcon() {
    switch (widget.template.mainCategory) {
      case "Business":
        return Icons.business_rounded;
      case "Real Estate":
        return Icons.real_estate_agent_rounded;
      case "Personal":
        return Icons.person_rounded;
      case "Legal":
        return Icons.gavel_rounded;
      case "HR":
        return Icons.people_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileType = (widget.template.fileType ?? "DOCX").toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Template Details",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 40,
                top: 20,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _getColor().withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(),
                      size: 64,
                      color: _getColor().withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if ((widget.template.sourceName ?? '').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.accentColor.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        "Sri Lanka ${(widget.template.sourceName!.length > 15) ? widget.template.sourceName!.split(' ').first : widget.template.sourceName}",
                        style: GoogleFonts.inter(
                          color: AppTheme.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Text(
                    widget.template.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          fileType,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${widget.template.mainCategory} • ${widget.template.subCategory}",
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Details",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(
                          icon: Icons.source_rounded,
                          title: "Source",
                          value:
                              widget.template.sourceName ?? "Standard Template",
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.format_list_bulleted_rounded,
                          title: "Category",
                          value: widget.template.mainCategory.toString(),
                        ),
                        const Divider(height: 24),
                        const _DetailRow(
                          icon: Icons.download_done_rounded,
                          title: "Downloads",
                          value: "1k+",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_isLoadingUrl)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_signedUrl == null)
                            ? null
                            : () {
                                if (fileType == "PDF") {
                                  _openPdfViewer(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Preview not supported for DOC/DOCX. Please download to view.',
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text("Preview Template"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: (_signedUrl == null || _isDownloading)
                            ? null
                            : () => _downloadAndOpenDoc(context),
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.download_rounded),
                        label: Text(
                          _isDownloading
                              ? "Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%"
                              : "Download & Open",
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: (_signedUrl == null)
                          ? null
                          : () => _launchUrlExternal(context, _signedUrl),
                      icon: const Icon(Icons.open_in_browser_rounded),
                      label: const Text("Open in Browser"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.inter(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              color: AppTheme.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
