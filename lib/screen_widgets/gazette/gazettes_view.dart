import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import 'gazette_filter_chips.dart';
import 'regular_gazette_card.dart';
import 'extraordinary_gazette_card.dart';
import '../../models/gazette_item.dart';
import '../../services/gazette_api_service.dart';

class GazettesView extends StatefulWidget {
  final String searchQuery;
  
  const GazettesView({super.key, this.searchQuery = ''});

  @override
  State<GazettesView> createState() => _GazettesViewState();
}

class _GazettesViewState extends State<GazettesView> {
  final List<String> filters = ["Latest", "Year", "English", "Sinhala", "Tamil"];
  
  final GazetteApiService _apiService = GazetteApiService();
  
  List<GazetteItem> regularGazettes = [];
  List<GazetteItem> extraordinaryGazettes = [];
  
  bool _isLoading = true;
  String? _selectedLang;
  int _selectedYear = 2026; // Default to 2026

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _apiService.fetchGazettes(type: 'regular', lang: _selectedLang, year: _selectedYear),
        _apiService.fetchGazettes(type: 'extraordinary', lang: _selectedLang, year: _selectedYear),
      ]);
      
      if (mounted) {
        setState(() {
          regularGazettes = futures[0];
          extraordinaryGazettes = futures[1];
          
          // Latest sort
          if (_selectedLang == null) {
            regularGazettes.sort((a, b) => (b.publishedDate ?? DateTime(0)).compareTo(a.publishedDate ?? DateTime(0)));
            extraordinaryGazettes.sort((a, b) => (b.publishedDate ?? DateTime(0)).compareTo(a.publishedDate ?? DateTime(0)));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load Gazettes: $e')),
        );
      }
    }
  }

  void _onFilterSelected(String filter) {
    if (filter == "English") {
      setState(() => _selectedLang = 'en');
      _fetchData();
    } else if (filter == "Sinhala") {
      setState(() => _selectedLang = 'si');
      _fetchData();
    } else if (filter == "Tamil") {
      setState(() => _selectedLang = 'ta');
      _fetchData();
    } else if (filter == "Latest") {
      setState(() => _selectedLang = null);
      _fetchData();
    } else if (filter == "Year") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Select Year', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [2026, 2025, 2024].map((y) => ListTile(
                title: Text(y.toString(), style: GoogleFonts.inter(fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedYear = y);
                  _fetchData();
                },
              )).toList(),
            ),
          );
        },
      );
    }
  }

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
            onSelected: _onFilterSelected,
          ),
          
          const SizedBox(height: 8),

          // Tab Content
          SizedBox(
            height: 500, // Fixed height or use shrinkWrap in actual implementation depending on layout
            child: TabBarView(
              children: [
                // Regular Gazettes Tab
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : regularGazettes.isEmpty
                        ? Center(child: Text("No gazettes found", style: GoogleFonts.inter(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: regularGazettes.length,
                            itemBuilder: (context, index) {
                              if (widget.searchQuery.isNotEmpty) {
                                final query = widget.searchQuery.toLowerCase();
                                final item = regularGazettes[index];
                                final matchesTitle = item.title.toLowerCase().contains(query);
                                final matchesType = item.gazetteType.toLowerCase().contains(query);
                                if (!matchesTitle && !matchesType) {
                                  return const SizedBox.shrink();
                                }
                              }
                              return RegularGazetteCard(item: regularGazettes[index]);
                            },
                          ),
                
                // Extraordinary Gazettes Tab
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : extraordinaryGazettes.isEmpty
                        ? Center(child: Text("No gazettes found", style: GoogleFonts.inter(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: extraordinaryGazettes.length,
                            itemBuilder: (context, index) {
                              if (widget.searchQuery.isNotEmpty) {
                                final query = widget.searchQuery.toLowerCase();
                                final item = extraordinaryGazettes[index];
                                final matchesTitle = item.title.toLowerCase().contains(query);
                                final matchesType = item.gazetteType.toLowerCase().contains(query);
                                if (!matchesTitle && !matchesType) {
                                  return const SizedBox.shrink();
                                }
                              }
                              return ExtraordinaryGazetteCard(
                                item: extraordinaryGazettes[index],
                                selectedYear: _selectedYear,
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
