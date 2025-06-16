import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define a Provider for the SettingsService
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// Define a service to manage user settings
class SettingsService {
  // Method to save the user's region
  Future<void> saveUserRegion(String region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRegion', region);
  }

  // Method to load the user's region
  Future<String?> loadUserRegion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRegion');
  }

  // Method to save notification preferences
  Future<void> saveNotificationPreferences(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
  }

  // Method to load notification preferences
  Future<bool> loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? true; // Default to enabled
  }

  // Method to save sync settings (e.g., sync on wifi only)
  Future<void> saveSyncSettings(bool syncOnWifiOnly) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('syncOnWifiOnly', syncOnWifiOnly);
  }

  // Method to load sync settings
  Future<bool> loadSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('syncOnWifiOnly') ?? false; // Default to sync on all networks
  }
}
