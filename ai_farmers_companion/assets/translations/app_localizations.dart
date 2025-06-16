import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_om.dart';
import 'app_localizations_so.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('om'),
    Locale('so')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Farmer\'s Companion'**
  String get appTitle;

  /// No description provided for @homeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Farmer\'s Companion'**
  String get homeScreenTitle;

  /// No description provided for @askAiButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAiButtonLabel;

  /// No description provided for @cropGuideButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop Guide'**
  String get cropGuideButtonLabel;

  /// No description provided for @pestDiseaseScannerButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Pest & Disease Scanner'**
  String get pestDiseaseScannerButtonLabel;

  /// No description provided for @marketIntelligenceButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Market Intelligence'**
  String get marketIntelligenceButtonLabel;

  /// No description provided for @weatherAlertsButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Weather Alerts'**
  String get weatherAlertsButtonLabel;

  /// No description provided for @learningLibraryButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Learning Library'**
  String get learningLibraryButtonLabel;

  /// No description provided for @communityGroupsButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Community & Groups'**
  String get communityGroupsButtonLabel;

  /// No description provided for @settingsButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsButtonLabel;

  /// No description provided for @askAiScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAiScreenTitle;

  /// No description provided for @askAiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type your question...'**
  String get askAiInputHint;

  /// No description provided for @voiceButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hold to Record'**
  String get voiceButtonTooltip;

  /// No description provided for @cropGuideScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Guide'**
  String get cropGuideScreenTitle;

  /// No description provided for @calendarViewPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Calendar View Placeholder'**
  String get calendarViewPlaceholder;

  /// No description provided for @regionSpecificTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Region-Specific Tips:'**
  String get regionSpecificTipsTitle;

  /// No description provided for @placeholderTip1.
  ///
  /// In en, this message translates to:
  /// **'Tip 1: Placeholder tip for the current region.'**
  String get placeholderTip1;

  /// No description provided for @placeholderTip2.
  ///
  /// In en, this message translates to:
  /// **'Tip 2: Another placeholder tip.'**
  String get placeholderTip2;

  /// No description provided for @pestPhotoUploadScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Pest & Disease Scanner'**
  String get pestPhotoUploadScreenTitle;

  /// No description provided for @selectImageButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImageButtonLabel;

  /// No description provided for @submitForAnalysisButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit for Analysis'**
  String get submitForAnalysisButtonLabel;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @languageSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingTitle;

  /// No description provided for @currentLanguagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get currentLanguagePlaceholder;

  /// No description provided for @lastSyncSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Last Sync'**
  String get lastSyncSettingTitle;

  /// No description provided for @neverSyncPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get neverSyncPlaceholder;

  /// No description provided for @helpGuideSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Guide'**
  String get helpGuideSettingTitle;

  /// No description provided for @offlineSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode - Last synced: {lastSyncTime}'**
  String offlineSyncStatus(String lastSyncTime);

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageAmharic.
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get languageAmharic;

  /// No description provided for @languageAfaanOromo.
  ///
  /// In en, this message translates to:
  /// **'Afaan Oromo'**
  String get languageAfaanOromo;

  /// No description provided for @languageSomali.
  ///
  /// In en, this message translates to:
  /// **'Somali'**
  String get languageSomali;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['am', 'en', 'om', 'so'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am': return AppLocalizationsAm();
    case 'en': return AppLocalizationsEn();
    case 'om': return AppLocalizationsOm();
    case 'so': return AppLocalizationsSo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
