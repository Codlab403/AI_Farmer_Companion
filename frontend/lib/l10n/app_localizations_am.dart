// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'የ አይ ገበሬ ባህሪ';

  @override
  String get login => 'ግባ';

  @override
  String get email => 'ኢሜይል';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get invalidEmail => 'የማይቀበል ኢሜይል';

  @override
  String get minChars => 'ቢያንስ 6 ቁምፊዎች';

  @override
  String get loginFailed => 'ግባት አልተሳካም';
}
