import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = ApiService.fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Forecast')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }

          final data = snapshot.data!;
          final hours = data['hours'] as List<dynamic>;

          return ListView.builder(
            itemCount: hours.length,
            itemBuilder: (context, index) {
              final hour = hours[index] as Map<String, dynamic>;
              return ListTile(
                leading: Text(hour['time'].substring(11, 16)),
                title: Text('${hour['temperature_c']}°C'),
                trailing: Text('${hour['precip_mm']} mm'),
              );
            },
          );
        },
      ),
    );
  }
}
