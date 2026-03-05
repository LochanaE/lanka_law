import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';

class GazetteFilterChips extends StatefulWidget {
  final List<String> filters;
  final Function(String) onSelected;
  
  const GazetteFilterChips({
    super.key,
    required this.filters,
    required this.onSelected,
  });

  @override
  State<GazetteFilterChips> createState() => _GazetteFilterChipsState();
}

class _GazetteFilterChipsState extends State<GazetteFilterChips> {
  String selectedFilter = '';

  @override
  void initState() {
    super.initState();
    if (widget.filters.isNotEmpty) {
      selectedFilter = widget.filters.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: widget.filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.white : AppTheme.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => selectedFilter = filter);
                  widget.onSelected(filter);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}
