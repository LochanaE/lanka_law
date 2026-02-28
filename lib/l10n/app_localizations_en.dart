// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Legal Assistant';

  @override
  String get chatHint => 'Type your legal question...';

  @override
  String get disclaimer =>
      'This app provides general legal information only, not professional advice.';

  @override
  String get topicMarriage => 'Marriage Registration';

  @override
  String get topicLand => 'Land Dispute';

  @override
  String get topicEPF => 'EPF/ETF Claims';

  @override
  String get welcomeMessage =>
      'Hello! I am your AI Legal Assistant. How can I help you today?';

  @override
  String get aiResponse =>
      'I can help you understand Sri Lankan laws regarding marriage, property, and labor. Please note that this is for informational purposes only.';
}
