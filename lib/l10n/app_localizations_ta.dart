// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'AI சட்ட உதவியாளர்';

  @override
  String get chatHint => 'உங்கள் சட்டக் கேள்வியைத் தட்டச்சு செய்க...';

  @override
  String get disclaimer =>
      'இந்த செயலி பொதுவான சட்டத் தகவல்களை மட்டுமே வழங்குகிறது, தொழில்முறை ஆலோசனை அல்ல.';

  @override
  String get topicMarriage => 'திருமண பதிவு';

  @override
  String get topicLand => 'நிலத் தகராறு';

  @override
  String get topicEPF => 'EPF/ETF கோரிக்கைகள்';

  @override
  String get welcomeMessage =>
      'வணக்கம்! நான் உங்கள் AI சட்ட உதவியாளர். இன்று உங்களுக்கு நான் எவ்வாறு உதவ முடியும்?';

  @override
  String get aiResponse =>
      'திருமணம், சொத்து மற்றும் தொழிலாளர் தொடர்பான இலங்கை சட்டங்களைப் புரிந்துகொள்ள நான் உங்களுக்கு தவி செய்கிறேன். இது தகவல் நோக்கங்களுக்காக மட்டுமே என்பதை நினைவில் கொள்க.';
}
