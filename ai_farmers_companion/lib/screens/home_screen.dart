import 'package:flutter/material.dart'; // Ensure Material is imported for AppLocalizations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/tile_button.dart'; // Import the TileButton widget
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
// Import other screen files as they are created

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // Get the localized strings

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeScreenTitle), // Use localized title
      ),
      body: Column( // Use a Column to place the banner above the grid
        children: [
          const SyncBanner(), // Add the SyncBanner widget
          Expanded( // Wrap the GridView in Expanded to take remaining space
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2, // Two tiles per row
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            TileButton(
              icon: Icons.chat_bubble_outline,
              label: l10n.askAiButtonLabel, // Use localized label
              onTap: () {
                Navigator.pushNamed(context, '/ask_ai');
              },
            ),
            TileButton(
              icon: Icons.calendar_today_outlined,
              label: l10n.cropGuideButtonLabel, // Use localized label
              onTap: () {
                Navigator.pushNamed(context, '/crop_guide');
              },
            ),
            TileButton(
              icon: Icons.camera_alt_outlined,
              label: l10n.pestDiseaseScannerButtonLabel, // Use localized label
              onTap: () {
                Navigator.pushNamed(context, '/pest_photo_upload');
              },
            ),
            TileButton(
              icon: Icons.storefront_outlined,
              label: l10n.marketIntelligenceButtonLabel, // Use localized label
              onTap: () {
                Navigator.pushNamed(context, '/market_intelligence');
              },
            ),
            TileButton(
              icon: Icons.cloud_outlined,
              label: l10n.weatherAlertsButtonLabel, // Use localized label
              onTap: () {
                Navigator.pushNamed(context, '/weather_alerts');
              },
            ),
            TileButton(
              icon: Icons.library_books_outlined,
              label: l10n.learningLibraryButtonLabel, // Use localized label
              onTap: () {
                Navigator.pushNamed(context, '/learning_library');
              },
            ),
            TileButton(
              icon: Icons.group_outlined,
              label: l10n.communityGroupsButtonLabel, // Use localized label
              onTap: () {
                Navigator.pushNamed(context, '/community_groups');
              },
            ),
            TileButton(
              icon: Icons.settings_outlined,
              label: l10n.settingsButtonLabel, // Use localized label
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            // TODO: Add TileButtons for other screens (Market Intelligence, Weather Alerts, Learning Library, Community & Groups)
          ],
        ),
      ),
    );
  }
}
