import 'package:flutter/material.dart';
import 'package:ai_farmers_companion/services/api_service.dart';

class CropInfoScreen extends StatefulWidget {
  const CropInfoScreen({super.key});

  @override
  State<CropInfoScreen> createState() => _CropInfoScreenState();
}

class _CropInfoScreenState extends State<CropInfoScreen> {
  Future<List<dynamic>>? _cropInfoData;

  @override
  void initState() {
    super.initState();
    _cropInfoData = ApiService.fetchCropInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Information')),
      body: FutureBuilder<List<dynamic>>(
        future: _cropInfoData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No crop information available.'));
          }

          final crops = snapshot.data!;
          return ListView.builder(
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.local_florist, color: Colors.green),
                  title: Text(crop['name'] ?? 'No name'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(crop['name'] ?? 'No name'),
                        content: Text(crop['description'] ?? 'No description available.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}


