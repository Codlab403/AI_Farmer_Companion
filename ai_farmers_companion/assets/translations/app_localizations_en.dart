// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Farmer\'s Companion';

  @override
  String get homeScreenTitle => 'AI Farmer\'s Companion';

  @override
  String get askAiButtonLabel => 'Ask AI';

  @override
  String get cropGuideButtonLabel => 'Crop Guide';

  @override
  String get pestDiseaseScannerButtonLabel => 'Pest & Disease Scanner';

  @override
  String get marketIntelligenceButtonLabel => 'Market Intelligence';

  @override
  String get weatherAlertsButtonLabel => 'Weather Alerts';

  @override
  String get learningLibraryButtonLabel => 'Learning Library';

  @override
  String get communityGroupsButtonLabel => 'Community & Groups';

  @override
  String get settingsButtonLabel => 'Settings';

  @override
  String get askAiScreenTitle => 'Ask AI';

  @override
  String get askAiInputHint => 'Type your question...';

  @override
  String get voiceButtonTooltip => 'Hold to Record';

  @override
  String get cropGuideScreenTitle => 'Crop Guide';

  @override
  String get calendarViewPlaceholder => 'Calendar View Placeholder';

  @override
  String get regionSpecificTipsTitle => 'Region-Specific Tips:';

  @override
  String get placeholderTip1 => 'Tip 1: Placeholder tip for the current region.';

  @override
  String get placeholderTip2 => 'Tip 2: Another placeholder tip.';

  @override
  String get pestPhotoUploadScreenTitle => 'Pest & Disease Scanner';

  @override
  String get selectImageButtonLabel => 'Select Image';

  @override
  String get submitForAnalysisButtonLabel => 'Submit for Analysis';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get currentLanguagePlaceholder => 'English';

  @override
  String get lastSyncSettingTitle => 'Last Sync';

  @override
  String get neverSyncPlaceholder => 'Never';

  @override
  String get helpGuideSettingTitle => 'Help Guide';

  @override
  String offlineSyncStatus(String lastSyncTime) {
    return 'Offline Mode - Last synced: $lastSyncTime';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageAmharic => 'Amharic';

  @override
  String get languageAfaanOromo => 'Afaan Oromo';

  @override
  String get languageSomali => 'Somali';
}
