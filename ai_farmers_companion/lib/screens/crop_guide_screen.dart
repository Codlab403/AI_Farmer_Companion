import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/crop_guide_service.dart'; // Import CropGuideService

class CropGuideScreen extends ConsumerStatefulWidget {
  const CropGuideScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CropGuideScreen> createState() => _CropGuideScreenState();
}

class _CropGuideScreenState extends ConsumerState<CropGuideScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CropTip> _tipsForSelectedDay = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchTipsForDate(_selectedDay!);
  }

  Future<void> _fetchTipsForDate(DateTime date) async {
    final cropGuideService = ref.read(cropGuideServiceProvider);
    final tips = await cropGuideService.getTipsForDate(date);
    setState(() {
      _tipsForSelectedDay = tips;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cropGuideScreenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _fetchTipsForDate(selectedDay);
                }
              },
              // TODO: Add more calendar configuration
            ),
            const SizedBox(height: 16.0),
            Text(
              l10n.regionSpecificTipsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: _tipsForSelectedDay.length,
                itemBuilder: (context, index) {
                  final tip = _tipsForSelectedDay[index];
                  return ListTile(
                    title: Text(tip.content),
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
