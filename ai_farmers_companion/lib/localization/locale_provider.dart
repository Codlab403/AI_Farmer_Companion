import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a StateProvider for the current Locale
final localeProvider = StateProvider<Locale>((ref) {
  // TODO: Implement logic to load initial locale from preferences or device settings
  return const Locale('en', ''); // Default to English
});
