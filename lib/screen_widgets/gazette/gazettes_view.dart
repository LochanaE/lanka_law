import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import 'gazette_filter_chips.dart';
import 'regular_gazette_card.dart';
import 'extraordinary_gazette_card.dart';

class GazettesView extends StatefulWidget {
  const GazettesView({super.key});

  @override
  State<GazettesView> createState() => _GazettesViewState();
}

class _GazettesViewState extends State<GazettesView> {
  final List<String> filters = ["Latest", "Year", "English", "Sinhala", "Tamil"];
  
  // Dummy data for demo
  final List<Map<String, String>> regularGazettes = [
    {"date": "27 Feb 2026", "partsAvailable": "Part I: Sec (I) - General"},
    {"date": "20 Feb 2026", "partsAvailable": "Part I: Sec (I), (IIA)"},
    {"date": "13 Feb 2026", "partsAvailable": "Part II: Legal, Part IV: Local Govt"},
  ];

  final List<Map<String, String>> extraordinaryGazettes = [
    {"issueNumber": "2473/12", "date": "02 Mar 2026", "subject": "Declaration of Essential Services"},
    {"issueNumber": "2472/34", "date": "25 Feb 2026", "subject": "Appointments by the President"},
    {"issueNumber": "2471/05", "date": "10 Feb 2026", "subject": "Regulations under Imports and Exports (Control) Act"},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textDark,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [
                  Tab(text: "Regular Gazette"),
                  Tab(text: "Extraordinary"),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filters
          GazetteFilterChips(
            filters: filters,
            onSelected: (filter) {
              // Handle filter selection here
            },
          ),
          
          const SizedBox(height: 8),

          // Tab Content
          SizedBox(
            height: 500, // Fixed height or use shrinkWrap in actual implementation depending on layout
            child: TabBarView(
              children: [
                // Regular Gazettes Tab
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: regularGazettes.length,
                  itemBuilder: (context, index) {
                    final item = regularGazettes[index];
                    return RegularGazetteCard(
                      date: item["date"]!,
                      partsAvailable: item["partsAvailable"]!,
                    );
                  },
                ),
                
                // Extraordinary Gazettes Tab
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: extraordinaryGazettes.length,
                  itemBuilder: (context, index) {
                    final item = extraordinaryGazettes[index];
                    return ExtraordinaryGazetteCard(
                      issueNumber: item["issueNumber"]!,
                      date: item["date"]!,
                      subject: item["subject"]!,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
