import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_tip.dart';
import '../services/daily_tip_api_service.dart';

class DailyTipProvider extends ChangeNotifier {
  final DailyTipApiService _apiService;
  
  DailyTip? _tip;
  bool _isLoading = false;
  String? _errorMessage;

  DailyTipProvider(this._apiService);

  DailyTip? get tip => _tip;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String _cacheKeyDate = 'daily_tip_date';
  static const String _cacheKeyData = 'daily_tip_data';

  Future<void> fetchTip({String? category, bool forceRefresh = false}) async {
    final todayStr = _getCurrentDateString();

    if (!forceRefresh) {
      final prefs = await SharedPreferences.getInstance();
      final cachedDate = prefs.getString(_cacheKeyDate);
      final cachedData = prefs.getString(_cacheKeyData);

      if (cachedDate == todayStr && cachedData != null) {
        try {
          _tip = DailyTip.fromJson(jsonDecode(cachedData));
          notifyListeners();
          print('💡 [DailyTipProvider] Loaded from cache for day: $todayStr');
          return;
        } catch (e) {
          print('❌ [DailyTipProvider] Failed to parse cached data: $e');
        }
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedTip = await _apiService.fetchDailyTip(category: category);
      _tip = fetchedTip;
      
      // Save to cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyDate, todayStr);
      await prefs.setString(_cacheKeyData, jsonEncode(fetchedTip.toJson()));
      
    } catch (e) {
      _errorMessage = 'Failed to load tip. Tap to retry.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
