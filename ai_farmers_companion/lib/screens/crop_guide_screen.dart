import 'package:flutter/material.dart'; // Ensure Material is imported for AppLocalizations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:table_calendar/table_calendar.dart'; // Import table_calendar
// Import other necessary packages

class CropGuideScreen extends ConsumerStatefulWidget {
  const CropGuideScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CropGuideScreen> createState() => _CropGuideScreenState();
}

class _CropGuideScreenState extends ConsumerState<CropGuideScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get the localized strings

    // TODO: Implement logic to fetch region-specific tips based on _selectedDay

    // Placeholder tips based on selected day (for demonstration)
    final List<String> tips = _selectedDay != null && _selectedDay!.day % 2 == 0
        ? [l10n.placeholderTip1]
        : [l10n.placeholderTip2];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cropGuideScreenTitle), // Use localized title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Implement Calendar View
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1), // Placeholder
              lastDay: DateTime.utc(2030, 12, 31), // Placeholder
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` as well
                });
                // TODO: Fetch and display tips for the selected day
              },
              // TODO: Add more calendar configuration
            ),
            const SizedBox(height: 16.0),
            Text(
              l10n.regionSpecificTipsTitle, // Use localized section title
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(tips[index]), // Display localized tips
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
