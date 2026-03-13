import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import 'package:lanka_law/models/legal_aid_provider.dart';
import 'package:lanka_law/data/mock_legal_aid_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalAidResultsListScreen extends StatefulWidget {
  const LegalAidResultsListScreen({super.key});

  @override
  State<LegalAidResultsListScreen> createState() => _LegalAidResultsListScreenState();
}

class _LegalAidResultsListScreenState extends State<LegalAidResultsListScreen> {
  late List<LegalAidProvider> _providers;
  String _searchQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _searchQuery = args;
    }
    _filterProviders();
  }

  void _filterProviders() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _providers = mockLegalAidProviders;
      } else {
        _providers = mockLegalAidProviders.where((p) {
          final query = _searchQuery.toLowerCase();
          return p.name.toLowerCase().contains(query) ||
              p.district.toLowerCase().contains(query) ||
              p.services.any((s) => s.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Results",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () => _showSortOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: _providers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _providers.length,
                    itemBuilder: (context, index) {
                      return _buildProviderCard(_providers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search...",
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) {
            _searchQuery = value;
            _filterProviders();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No providers found",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight),
          ),
          Text(
            "Try adjusting your search or filters",
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(LegalAidProvider provider) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/legal_aid_detail', arguments: provider);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (provider.isVerified)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(Icons.verified_rounded, color: Colors.blue, size: 16),
                            ),
                          Expanded(
                            child: Text(
                              provider.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textLight),
                          const SizedBox(width: 4),
                          Text(
                            provider.district,
                            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.access_time_filled_rounded, size: 14, color: AppTheme.textLight),
                          const SizedBox(width: 4),
                          Text(
                            provider.isOpenNow ? "Open Now" : "Closed",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: provider.isOpenNow ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag(provider.isFreeAid ? "Free Aid" : "Subsidized", isPrimary: provider.isFreeAid),
                ...provider.services.take(2).map((s) => _buildTag(s)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.translate_rounded, size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 6),
                      Text(
                        provider.languages.join(", "),
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                ),
                _buildCircularAction(Icons.call_rounded, Colors.green, () {
                  launchUrl(Uri.parse("tel:${provider.phone}"));
                }),
                const SizedBox(width: 10),
                _buildCircularAction(Icons.directions_rounded, Colors.blue, () {
                  // Open maps placeholder
                  launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(provider.name + " " + provider.address)}"));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primaryColor.withOpacity(0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isPrimary ? AppTheme.primaryColor : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildCircularAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sort By", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ListTile(leading: const Icon(Icons.near_me_rounded), title: const Text("Nearest"), onTap: () => Navigator.pop(context)),
              ListTile(leading: const Icon(Icons.star_rounded), title: const Text("Rating"), onTap: () => Navigator.pop(context)),
              ListTile(leading: const Icon(Icons.timer_rounded), title: const Text("Currently Open"), onTap: () => Navigator.pop(context)),
            ],
          ),
        );
      },
    );
  }
}
