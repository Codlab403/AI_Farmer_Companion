import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database_helper.dart'; // Import DatabaseHelper
import 'api_service.dart'; // Import ApiService

// Define synchronization status enum
enum SyncStatus {
  synced,
  added,
  modified,
  deleted,
}

// Define a simple data structure for a crop tip
class CropTip {
  final int? id;
  final String date;
  final String region;
  final String content;
  final SyncStatus syncStatus; // Add sync status field

  CropTip({this.id, required this.date, required this.region, required this.content, this.syncStatus = SyncStatus.synced});

  // Convert a CropTip object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'region': region,
      'content': content,
      'syncStatus': syncStatus.index, // Store enum index
    };
  }

  // Extract a CropTip object from a Map object
  factory CropTip.fromMap(Map<String, dynamic> map) {
    return CropTip(
      id: map['id'],
      date: map['date'],
      region: map['region'],
      content: map['content'],
      syncStatus: SyncStatus.values[map['syncStatus']], // Convert index back to enum
    );
  }
}

// Define a Provider for the CropGuideService
final cropGuideServiceProvider = Provider<CropGuideService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CropGuideService(apiService: apiService);
});

// Define a service to provide crop guide tips and handle their synchronization
class CropGuideService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ApiService _apiService;

  CropGuideService({required ApiService apiService}) : _apiService = apiService {
    _insertSampleTips(); // Insert sample data when the service is initialized
  }

  // Method to get tips for a given date and optional region from the database
  Future<List<CropTip>> getTipsForDate(DateTime date, {String? region}) async {
    final db = await _databaseHelper.database;
    final dateString = "${date.year}-${date.month}-${date.day}";

    // Query the database for tips matching the date and optional region
    String whereClause = 'date = ?';
    List<dynamic> whereArgs = [dateString];

    if (region != null && region.isNotEmpty) {
      whereClause += ' AND region = ?';
      whereArgs.add(region);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'crop_tips',
      where: whereClause,
      whereArgs: whereArgs,
    );

    // Convert the List<Map<String, dynamic>> into a List<CropTip>
    return List.generate(maps.length, (i) {
      return CropTip.fromMap(maps[i]);
    });
  }

  // Method to insert a list of crop tips into the database
  Future<void> insertTips(List<CropTip> tips) async {
    final db = await _databaseHelper.database;
    for (var tip in tips) {
      await db.insert(
        'crop_tips',
        tip.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Replace if tip with same ID exists
      );
    }
  }

  // Temporary method to insert sample crop tips data
  Future<void> _insertSampleTips() async {
    final sampleTips = [
      CropTip(date: '2025-06-16', region: 'Region A', content: 'Sample Tip 1 for June 16'),
      CropTip(date: '2025-06-16', region: 'Region B', content: 'Sample Tip 2 for June 16'),
      CropTip(date: '2025-06-17', region: 'Region A', content: 'Sample Tip 1 for June 17'),
      CropTip(date: '2025-06-18', region: 'Region C', content: 'Sample Tip 1 for June 18'),
    ];
    await insertTips(sampleTips);
  }

  // Method to get unsynced crop tips from the database
  Future<List<CropTip>> getUnsyncedTips() async {
    print('Getting unsynced crop tips...');
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'crop_tips',
      where: 'syncStatus != ?',
      whereArgs: [SyncStatus.synced.index],
    );
    return List.generate(maps.length, (i) {
      return CropTip.fromMap(maps[i]);
    });
  }

  // Method to mark a list of tips as synced
  Future<void> markTipsAsSynced(List<CropTip> tips) async {
    print('Marking tips as synced...');
    final db = await _databaseHelper.database;
    final batch = db.batch();
    for (var tip in tips) {
      batch.update(
        'crop_tips',
        {'syncStatus': SyncStatus.synced.index},
        where: 'id = ?',
        whereArgs: [tip.id],
      );
    }
    await batch.commit();
    print('Tips marked as synced.');
  }

  // Method to merge remote crop tips data into the local database
  Future<void> mergeRemoteTips(List<CropTip> remoteTips) async {
    print('Merging remote crop tips...');
    final db = await _databaseHelper.database;
    final batch = db.batch();
    for (var remoteTip in remoteTips) {
      // Check if tip exists locally
      final existingTips = await db.query(
        'crop_tips',
        where: 'id = ?',
        whereArgs: [remoteTip.id],
      );

      if (existingTips.isNotEmpty) {
        // Update existing tip
        batch.update(
          'crop_tips',
          remoteTip.toMap(),
          where: 'id = ?',
          whereArgs: [remoteTip.id],
        );
      } else {
        // Insert new tip
        batch.insert(
          'crop_tips',
          remoteTip.toMap(),
        );
      }
    }
    await batch.commit();
    print('Remote tips merged.');
  }

  // Method to synchronize crop tips data (called by SynchronizationService)
  Future<void> synchronizeCropTips() async {
    print('Synchronizing crop tips...');
    // Push local changes
    final unsyncedTips = await getUnsyncedTips();
    if (unsyncedTips.isNotEmpty) {
      await _apiService.pushCropTips(unsyncedTips);
      // Mark pushed tips as synced in the local database after successful push
      await markTipsAsSynced(unsyncedTips);
    }

    // Pull remote updates
    final remoteTips = await _apiService.fetchLatestCropTips();
    await mergeRemoteTips(remoteTips);

    print('Crop tips synchronization complete.');
  }
}
