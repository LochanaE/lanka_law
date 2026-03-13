import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import 'package:lanka_law/models/legal_aid_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalAidPlaceDetailScreen extends StatelessWidget {
  const LegalAidPlaceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = ModalRoute.of(context)!.settings.arguments as LegalAidProvider;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, provider),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(provider),
                  const SizedBox(height: 20),
                  _buildTags(provider),
                  const SizedBox(height: 24),
                  _buildActionsRow(provider, context),
                  const SizedBox(height: 30),
                  _buildSection("About", provider.about ?? "No description available."),
                  const SizedBox(height: 24),
                  _buildServicesSection(provider),
                  const SizedBox(height: 24),
                  _buildSection("Eligibility", provider.isFreeAid ? "This service is free for low-income citizens who meet the Legal Aid Commission's criteria." : "Subsidized legal assistance for qualified applicants."),
                  const SizedBox(height: 24),
                  _buildSection("Working Hours", provider.workingHours ?? "Not specified"),
                  if (provider.documentsByService != null) ...[
                    const SizedBox(height: 24),
                    _buildDocumentsSection(provider),
                  ],
                  const SizedBox(height: 40),
                  _buildRequestAppointmentCTA(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, LegalAidProvider provider) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
            Center(
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.account_balance_rounded, size: 100, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeader(LegalAidProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                provider.name,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            if (provider.isVerified)
              const Icon(Icons.verified_rounded, color: Colors.blue, size: 28),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.textLight),
            const SizedBox(width: 4),
            Text(
              provider.district,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
            ),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: provider.isOpenNow ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                provider.isOpenNow ? "OPEN NOW" : "CLOSED",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: provider.isOpenNow ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTags(LegalAidProvider provider) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildDetailTag(provider.isFreeAid ? "FREE AID" : "SUBSIDIZED", isGold: provider.isFreeAid),
        ...provider.languages.map((l) => _buildDetailTag(l)),
      ],
    );
  }

  Widget _buildDetailTag(String text, {bool isGold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isGold ? AppTheme.accentColor.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isGold ? AppTheme.accentColor : Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isGold ? AppTheme.primaryColor : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildActionsRow(LegalAidProvider provider, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCircleAction(Icons.call_rounded, "Call", () => launchUrl(Uri.parse("tel:${provider.phone}"))),
        if (provider.whatsapp != null)
          _buildCircleAction(Icons.chat_rounded, "WhatsApp", () => launchUrl(Uri.parse("https://wa.me/${provider.whatsapp}"))),
        _buildCircleAction(Icons.email_rounded, "Email", () => launchUrl(Uri.parse("mailto:${provider.email}"))),
        _buildCircleAction(Icons.directions_rounded, "Directions", () => launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(provider.name + " " + provider.address)}"))),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textLight),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildServicesSection(LegalAidProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Services Offered",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.services.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(s, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryColor)),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(LegalAidProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Documents to Bring",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: provider.documentsByService!.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  ...entry.value.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.remove, size: 12, color: AppTheme.textLight),
                        const SizedBox(width: 8),
                        Expanded(child: Text(doc, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestAppointmentCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Ready to take the next step?",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Request an appointment with this office directly through the app.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Appointment request feature coming soon!")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              elevation: 0,
            ),
            child: const Text("Request Appointment"),
          ),
        ],
      ),
    );
  }
}
