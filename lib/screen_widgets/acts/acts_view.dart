import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import '../../models/act_group.dart';
import '../../services/acts_api_service.dart';
import 'act_card.dart';
import '../gazette/gazette_filter_chips.dart';

class ActsView extends StatefulWidget {
  final String searchQuery;

  const ActsView({super.key, this.searchQuery = ''});

  @override
  State<ActsView> createState() => _ActsViewState();
}

class _ActsViewState extends State<ActsView> {
  final List<String> filters = ["Latest", "Year", "English", "Sinhala", "Tamil"];
  final ActsApiService _apiService = ActsApiService();
  
  List<ActGroup> groupedActs = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedLang;
  int _selectedYear = 2026;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Pass null as language initially to get all acts, or use selected language
      final items = await _apiService.fetchActs(lang: _selectedLang, year: _selectedYear);
      
      // Group by act_no
      Map<String, ActGroup> groups = {};
      for (var item in items) {
        final actNo = item.actNo ?? 'unknown_act_no';
        if (!groups.containsKey(actNo)) {
          groups[actNo] = ActGroup(actNo: actNo);
        }
        final group = groups[actNo]!;
        
        switch (item.language?.toLowerCase()) {
          case 'en':
            group.en = item;
            break;
          case 'si':
            group.si = item;
            break;
          case 'ta':
            group.ta = item;
            break;
          default:
            // Fallback to en if unspecified
            group.en = item;
        }
      }

      final list = groups.values.toList();
      
      // Sorting: newest published_date first (descending)
      list.sort((a, b) => (b.publishedDate ?? DateTime(0)).compareTo(a.publishedDate ?? DateTime(0)));

      // If user selected a specific language preference via chips (e.g. English, Sinhala, Tamil), 
      // we prioritize/sort those groups where the selected language exists first.
      if (_selectedLang != null) {
        list.sort((a, b) {
          bool aHasEn = a.hasEn;
          bool bHasEn = b.hasEn;
          bool aHasSi = a.hasSi;
          bool bHasSi = b.hasSi;
          bool aHasTa = a.hasTa;
          bool bHasTa = b.hasTa;

          int aScore = (_selectedLang == 'en' && aHasEn) ? 1 : (_selectedLang == 'si' && aHasSi) ? 1 : (_selectedLang == 'ta' && aHasTa) ? 1 : 0;
          int bScore = (_selectedLang == 'en' && bHasEn) ? 1 : (_selectedLang == 'si' && bHasSi) ? 1 : (_selectedLang == 'ta' && bHasTa) ? 1 : 0;
          
          if (aScore != bScore) {
            return bScore.compareTo(aScore);
          }
          // fallback to date desc
          return (b.publishedDate ?? DateTime(0)).compareTo(a.publishedDate ?? DateTime(0));
        });
      }

      if (mounted) {
        setState(() {
          groupedActs = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
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
      setState(() {
        _selectedLang = null;
        _selectedYear = DateTime.now().year; 
      });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title or visual indicator (if any matching gazette)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            "Parliamentary Acts",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        
        // Match gazette filters design exactly
        GazetteFilterChips(
          filters: filters,
          onSelected: _onFilterSelected,
        ),
        
        const SizedBox(height: 16),

        // List / State Handling
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
          )
        else if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Error loading acts", style: GoogleFonts.inter(color: Colors.red)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _fetchData,
                    style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (groupedActs.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Center(child: Text("No acts found", style: GoogleFonts.inter(color: Colors.grey))),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: groupedActs.length,
            itemBuilder: (context, index) {
              if (widget.searchQuery.isNotEmpty) {
                final query = widget.searchQuery.toLowerCase();
                final group = groupedActs[index];
                final matchesTitle = group.displayTitle.toLowerCase().contains(query);
                if (!matchesTitle) {
                  return const SizedBox.shrink();
                }
              }
              return ActCard(group: groupedActs[index]);
            },
          ),
      ],
    );
  }
}
