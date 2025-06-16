import 'dart:async'; // Import for StreamSubscription
import 'package:flutter/material.dart';
import 'package:ai_farmers_companion/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase client

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  List<dynamic> _marketData = []; // Use a List to hold real-time data
  bool _isLoading = true; // Add loading state
  String? _error; // Add error state
  StreamSubscription<List<Map<String, dynamic>>>? _marketPricesSubscription; // Supabase Realtime Subscription

  @override
  void initState() {
    super.initState();
    _fetchInitialMarketPrices(); // Fetch initial data
    _subscribeToMarketPriceUpdates(); // Subscribe to real-time updates
  }

  @override
  void dispose() {
    _marketPricesSubscription?.cancel(); // Cancel the subscription on dispose
    super.dispose();
  }

  Future<void> _fetchInitialMarketPrices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Fetch initial data using the existing API service method
      final initialData = await ApiService.fetchMarketPrices();
      setState(() {
        _marketData = initialData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load initial market prices.';
        _isLoading = false;
      });
      print('Error fetching initial market prices: $e');
    }
  }

  void _subscribeToMarketPriceUpdates() {
    final supabase = Supabase.instance.client;
    _marketPricesSubscription = supabase
        .from('market_prices') // Assuming your table name is 'market_prices'
        .stream(primaryKey: ['id']) // Assuming 'id' is the primary key
        .listen((List<Map<String, dynamic>> data) {
          // Handle incoming real-time data (inserts, updates, deletes)
          _handleRealtimeMarketPriceUpdate(data);
        });
  }

  void _handleRealtimeMarketPriceUpdate(List<Map<String, dynamic>> changes) {
    // Process the incoming changes and update the _marketData list
    setState(() {
      for (final change in changes) {
        final newRecord = change['new'];
        final oldRecord = change['old'];
        final eventType = change['eventType'];

        if (eventType == 'INSERT') {
          // Add new record if it doesn't exist
          if (!_marketData.any((item) => item['id'] == newRecord['id'])) {
            _marketData.add(newRecord);
          }
        } else if (eventType == 'UPDATE') {
          // Find and update the existing record
          final index = _marketData.indexWhere((item) => item['id'] == newRecord['id']);
          if (index != -1) {
            _marketData[index] = newRecord;
          }
        } else if (eventType == 'DELETE') {
          // Remove the deleted record
          _marketData.removeWhere((item) => item['id'] == oldRecord['id']);
        }
      }
      // Optionally re-sort the data if needed (e.g., by date or crop type)
      // _marketData.sort((a, b) => a['date'].compareTo(b['date']));
    });
    print('DEBUG - Realtime market price update received. Current data count: ${_marketData.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market Prices')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _marketData.isEmpty
                  ? const Center(child: Text('No market data available.'))
                  : ListView.builder(
                      itemCount: _marketData.length,
                      itemBuilder: (context, index) {
                        final item = _marketData[index];
                        // Ensure keys exist before accessing
                        final crop = item['crop_type'] ?? 'Unknown Crop';
                        final price = item['price_per_kg']?.toString() ?? 'N/A';
                        final unit = item['currency'] ?? 'ETB';
                        final region = item['region'] ?? 'N/A';
                        final date = item['date'] ?? 'N/A';

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.bar_chart, color: Colors.green),
                            title: Text('$crop - $region', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Date: $date'),
                            trailing: Text('$price $unit', style: const TextStyle(fontSize: 16)),
                          ),
                        );
                      },
                    ),
    );
  }
}
