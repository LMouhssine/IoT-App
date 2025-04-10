import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/device_service.dart';
import '../services/settings_service.dart';
import '../services/firebase_service.dart';
import '../widgets/nav_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceService = Provider.of<DeviceService>(context);
    final settingsService = Provider.of<SettingsService>(context);
    final firebaseService = Provider.of<FirebaseService>(context);
    final data = deviceService.history.isNotEmpty ? deviceService.history : _generateDataFromFirebase(firebaseService);
    final unit = settingsService.temperatureUnit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              firebaseService.fetchHistoricalData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Actualisation des données...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: data.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune donnée disponible'),
                ],
              ),
            )
          : Column(
              children: [
                // Graphique
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: const FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            // Courbe de température
                            LineChartBarData(
                              spots: data.asMap().entries.map((entry) {
                                return FlSpot(
                                  entry.key.toDouble(),
                                  entry.value['temperature'] as double,
                                );
                              }).toList(),
                              isCurved: true,
                              color: Colors.orange,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // En-tête de liste
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Relevés récents',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                
                // Liste des relevés
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    child: ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final reading = data[index];
                        final temp = reading['temperature'] as double;
                        final humidity = reading['humidity'];
                        final timestamp = reading['timestamp'] is DateTime
                            ? reading['timestamp'] as DateTime
                            : DateTime.fromMillisecondsSinceEpoch(
                                reading['timestamp'] as int,
                              );
                        
                        return ListTile(
                          title: Text('${temp.toStringAsFixed(1)}$unit / $humidity%'),
                          subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(timestamp)),
                          leading: Icon(
                            Icons.thermostat_outlined,
                            color: temp > settingsService.threshold ? Colors.red : Colors.orange,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const NavBar(currentIndex: 2),
    );
  }
  
  List<Map<String, dynamic>> _generateDataFromFirebase(FirebaseService firebaseService) {
    final result = <Map<String, dynamic>>[];
    
    if (firebaseService.dataHistory.isNotEmpty) {
      for (var entry in firebaseService.dataHistory) {
        if (entry['DHT11'] != null && entry['DHT11'] is Map) {
          final dht11Data = entry['DHT11'] as Map;
          final timestamp = entry['timestamp'] ?? DateTime.now().millisecondsSinceEpoch;
          
          double? temp;
          double? humidity;
          
          if (dht11Data['Temperature'] != null) {
            temp = _parseDoubleValue(dht11Data['Temperature']);
          }
          
          if (dht11Data['Humidity'] != null) {
            humidity = _parseDoubleValue(dht11Data['Humidity']);
          }
          
          if (temp != null && humidity != null) {
            result.add({
              'temperature': temp,
              'humidity': humidity,
              'timestamp': timestamp,
            });
          }
        }
      }
    }
    
    return result;
  }
  
  double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}