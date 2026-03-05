import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lanka_law/theme.dart';
import '../../models/act_group.dart';
import '../../models/act_item.dart';
import '../../services/acts_api_service.dart';
import '../pdf_viewer_screen.dart';

class ActCard extends StatefulWidget {
  final ActGroup group;

  const ActCard({super.key, required this.group});

  @override
  State<ActCard> createState() => _ActCardState();
}

class _ActCardState extends State<ActCard> {
  bool _isLoading = false;
  String? _loadingLang;

  Future<void> _openLanguagePdf(String langCode, ActItem item) async {
    setState(() {
      _isLoading = true;
      _loadingLang = langCode;
    });

    try {
      final service = ActsApiService();
      final url = await service.fetchSignedUrl(item.id);

      if (mounted) {
        // Fallback to url_launcher since PdfViewerScreen might struggle with some device constraints
        // as requested by 'externalApplication' mode.
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Alternatively, let's use the in-app PdfViewerScreen for consistency with Gazettes
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                url: url,
                title: widget.group.displayTitle,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load Act PDF: $e')),
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
    final dateStr = widget.group.publishedDate != null
        ? DateFormat('dd MMM yyyy').format(widget.group.publishedDate!)
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
                      widget.group.actNo ?? '-',
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
                widget.group.displayTitle,
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
                    isAvailable: widget.group.hasEn,
                    isLoading: _isLoading && _loadingLang == "EN",
                    onTap: widget.group.hasEn && !_isLoading
                        ? () => _openLanguagePdf("EN", widget.group.en!)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _LanguageButton(
                    lang: "SI",
                    isAvailable: widget.group.hasSi,
                    isLoading: _isLoading && _loadingLang == "SI",
                    onTap: widget.group.hasSi && !_isLoading
                        ? () => _openLanguagePdf("SI", widget.group.si!)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _LanguageButton(
                    lang: "TA",
                    isAvailable: widget.group.hasTa,
                    isLoading: _isLoading && _loadingLang == "TA",
                    onTap: widget.group.hasTa && !_isLoading
                        ? () => _openLanguagePdf("TA", widget.group.ta!)
                        : null,
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
  final bool isAvailable;

  const _LanguageButton({
    required this.lang,
    required this.onTap,
    this.isLoading = false,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    // If not available, we disable the button visually instead of hiding it,
    // keeping layout stable or we can just hide it as per design choice.
    // The instructions say "disable if that language file is not available".
    final opacity = isAvailable ? 1.0 : 0.3;

    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: isAvailable ? Colors.transparent : Colors.grey.shade100,
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
                    color: isAvailable ? AppTheme.primaryColor : Colors.grey.shade500,
                  ),
                ),
        ),
      ),
    );
  }
}
