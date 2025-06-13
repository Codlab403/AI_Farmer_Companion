import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ai_farmers_companion/services/api_service.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  Future<List<dynamic>>? _marketData;

  @override
  void initState() {
    super.initState();
    _marketData = ApiService.fetchMarketPrices();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market Prices')),
      body: FutureBuilder<List<dynamic>>(
        future: _marketData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No market data available.'));
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.bar_chart, color: Colors.green),
                  title: Text(item['crop'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(item['price'], style: const TextStyle(fontSize: 16)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

