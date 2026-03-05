import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lanka_law/theme.dart';
import '../../models/gazette_item.dart';
import '../../services/gazette_api_service.dart';
import '../pdf_viewer_screen.dart';

class ExtraordinaryGazetteCard extends StatefulWidget {
  final GazetteItem item;
  final int selectedYear;

  const ExtraordinaryGazetteCard({
    super.key,
    required this.item,
    required this.selectedYear,
  });

  @override
  State<ExtraordinaryGazetteCard> createState() => _ExtraordinaryGazetteCardState();
}

class _ExtraordinaryGazetteCardState extends State<ExtraordinaryGazetteCard> {
  bool _isLoading = false;
  String? _loadingLang;

  Future<void> _openLanguagePdf(String langCode) async {
    setState(() {
      _isLoading = true;
      _loadingLang = langCode;
    });

    try {
      final service = GazetteApiService();
      // Fetch gazettes for this language and matching issueNo
      final list = await service.fetchGazettes(
        type: 'extraordinary',
        lang: langCode.toLowerCase(),
        year: widget.selectedYear,
      );

      final matching = list.where((e) => e.issueNo == widget.item.issueNo).toList();

      if (matching.isNotEmpty) {
        final targetItem = matching.first;
        final url = await service.fetchSignedUrl(targetItem.id);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                url: url,
                title: targetItem.title,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No $langCode version found for this issue.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingLang = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.item.publishedDate != null
        ? DateFormat('dd MMM yyyy').format(widget.item.publishedDate!)
        : 'Unknown Date';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.item.issueNo ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.item.title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Language Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _LanguageButton(
                    lang: "EN",
                    isLoading: _isLoading && _loadingLang == "EN",
                    onTap: _isLoading ? null : () => _openLanguagePdf("EN"),
                  ),
                  const SizedBox(width: 8),
                  _LanguageButton(
                    lang: "SI",
                    isLoading: _isLoading && _loadingLang == "SI",
                    onTap: _isLoading ? null : () => _openLanguagePdf("SI"),
                  ),
                  const SizedBox(width: 8),
                  _LanguageButton(
                    lang: "TA",
                    isLoading: _isLoading && _loadingLang == "TA",
                    onTap: _isLoading ? null : () => _openLanguagePdf("TA"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String lang;
  final VoidCallback? onTap;
  final bool isLoading;

  const _LanguageButton({
    required this.lang,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              )
            : Text(
                lang,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
      ),
    );
  }
}
