import 'package:flutter/material.dart';
import '../models/template_item.dart';
import '../services/templates_api_service.dart';

class TemplatesProvider extends ChangeNotifier {
  final TemplatesApiService _apiService = TemplatesApiService();

  String _selectedMainTab = "Business";

  final Map<String, int> _selectedSubCategoryIndices = {
    "Business": 0,
    "Real Estate": 0,
    "Personal": 0,
    "Legal": 0,
    "HR": 0,
  };

  final Map<String, List<String>> categorySubcategoryMap = {
    "Business": [
      "All",
      "Company (ROC)",
      "Filings",
      "Directors",
      "Shares",
      "Charges",
      "Affidavits",
      // "Contracts", // ✅ remove for now unless backend has data
    ],
    "Real Estate": [
      "All",
      "Lease/Rent",
      "Transfer/Deed",
      "Mortgage/Loan",
      "Survey/Planning",
      "Taxes/Stamp Duty",
      "Approvals",
    ],
    "Personal": ["All", "Passports", "Visas", "NIC", "Clearance"],
    "Legal": [
      "All",
      "RTI Requests",
      "RTI Decisions",
      "RTI Appeals",
      "RTI Registers",
    ],
    "HR": [
      "All",
      "EPF Registration",
      "EPF Claims",
      "EPF Member Details",
      "Refunds",
    ],
  };

  String _searchQuery = "";
  bool _isLoading = false;
  String? _errorMessage;

  List<TemplateItem> _allTemplates = [];
  List<TemplateItem> _featuredTemplates = [];

  // Getters
  String get selectedMainTab => _selectedMainTab;
  int get selectedSubCategoryIndex =>
      _selectedSubCategoryIndices[_selectedMainTab] ?? 0;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TemplateItem> get featuredTemplates => _featuredTemplates;

  List<TemplateItem> get filteredTemplates {
    var result = _allTemplates;

    final currentIndex = selectedSubCategoryIndex;
    if (currentIndex != 0) {
      final subCatsList = categorySubcategoryMap[_selectedMainTab];
      if (subCatsList != null && currentIndex < subCatsList.length) {
        final activeSubCategory = subCatsList[currentIndex];
        result = result
            .where((item) => item.subCategory == activeSubCategory)
            .toList();
      }
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((item) {
        final title = item.title.toLowerCase();
        final desc = item.description?.toLowerCase() ?? '';
        final source = item.sourceName?.toLowerCase() ?? '';
        return title.contains(query) ||
            desc.contains(query) ||
            source.contains(query);
      }).toList();
    }

    return result;
  }

  // Actions
  void setMainTab(String tabName, {String lang = 'en'}) {
    if (_selectedMainTab != tabName) {
      _selectedMainTab = tabName;
      _selectedSubCategoryIndices[tabName] = 0;
      _searchQuery = "";
      notifyListeners();
      fetchTemplates(lang: lang);
    }
  }

  void setSubCategoryIndex(int index) {
    _selectedSubCategoryIndices[_selectedMainTab] = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchTemplates({String lang = 'en'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ Debug prints
      print('[TemplatesProvider] tab=$_selectedMainTab lang=$lang');

      final results = await Future.wait([
        _apiService.fetchTemplates(category: _selectedMainTab, lang: lang),
        _apiService.fetchTemplates(
          category: _selectedMainTab,
          lang: lang,
          featuredOnly: true,
        ),
      ]);

      _allTemplates = results[0];
      _featuredTemplates = results[1];

      print(
        '[TemplatesProvider] all=${_allTemplates.length} featured=${_featuredTemplates.length}',
      );
    } catch (e) {
      _errorMessage = e.toString();
      print('[TemplatesProvider] error=$_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Signed URL needs UUID String
  Future<String> getSignedUrl(String id) async {
    return await _apiService.getSignedUrl(id);
  }
}
