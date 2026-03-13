import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalAidFinderHomeScreen extends StatefulWidget {
  const LegalAidFinderHomeScreen({super.key});

  @override
  State<LegalAidFinderHomeScreen> createState() => _LegalAidFinderHomeScreenState();
}

class _LegalAidFinderHomeScreenState extends State<LegalAidFinderHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Legal Aid Finder",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildFilterChips(),
            const SizedBox(height: 30),
            _buildQuickActions(),
            const SizedBox(height: 30),
            _buildEmergencyCard(),
            const SizedBox(height: 30),
            _buildSectionHeader("Nearest Help", onSeeAll: () {}),
            const SizedBox(height: 15),
            _buildNearestHelpList(),
            const SizedBox(height: 30),
            _buildSectionHeader("Popular Services", showSeeAll: false),
            const SizedBox(height: 15),
            _buildPopularServicesGrid(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search by city / office / service...",
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textLight),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onSubmitted: (value) {
          Navigator.pushNamed(context, '/legal_aid_results', arguments: value);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["Location", "Case Type", "Free/Paid", "Language", "Open Now"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(filter),
              onSelected: (selected) {
                _showFilterBottomSheet(filter);
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryColor.withOpacity(0.1),
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFilterBottomSheet(String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filter by $title",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text("Filter options will be listed here..."),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Apply Filter"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            "Use Wizard",
            Icons.auto_awesome_rounded,
            AppTheme.primaryGradient,
            () {
              Navigator.pushNamed(context, '/legal_aid_wizard');
            },
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionButton(
            "Browse All",
            Icons.grid_view_rounded,
            const LinearGradient(colors: [Colors.white, Colors.white]),
            () {
              Navigator.pushNamed(context, '/legal_aid_results');
            },
            isOutlined: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    LinearGradient gradient,
    VoidCallback onTap, {
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isOutlined ? null : gradient,
          color: isOutlined ? Colors.white : null,
          borderRadius: BorderRadius.circular(16),
          border: isOutlined ? Border.all(color: AppTheme.primaryColor) : null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(isOutlined ? 0.05 : 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isOutlined ? AppTheme.primaryColor : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: isOutlined ? AppTheme.primaryColor : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emergency_rounded, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emergency Help",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red.shade900,
                  ),
                ),
                Text(
                  "Immediate legal assistance hotlines",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showEmergencyBottomSheet(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text("Call Now"),
          ),
        ],
      ),
    );
  }

  void _showEmergencyBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Emergency Hotlines",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildHotlineItem("Legal Aid Commission", "0112433618"),
              _buildHotlineItem("Women & Children Desk", "1929"),
              _buildHotlineItem("Police Emergency", "119"),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHotlineItem(String name, String number) {
    return ListTile(
      title: Text(name),
      subtitle: Text(number),
      trailing: IconButton(
        icon: const Icon(Icons.call_rounded, color: Colors.green),
        onPressed: () => launchUrl(Uri.parse("tel:$number")),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showSeeAll = true, VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: onSeeAll,
            child: const Text("See All"),
          ),
      ],
    );
  }

  Widget _buildNearestHelpList() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, color: AppTheme.primaryColor, size: 16),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "OPEN",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Legal Aid Office ${index + 1}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "0.5 km • Colombo District",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildSmallTag("Free"),
                    const SizedBox(width: 5),
                    _buildSmallTag("English"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 10, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildPopularServicesGrid() {
    final services = [
      {"name": "Traffic", "icon": Icons.traffic_rounded},
      {"name": "Family", "icon": Icons.family_restroom_rounded},
      {"name": "Labour", "icon": Icons.work_rounded},
      {"name": "Property", "icon": Icons.home_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Icon(services[index]["icon"] as IconData, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Text(
                services[index]["name"] as String,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}
