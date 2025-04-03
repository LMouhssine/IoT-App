import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/device_service.dart';
import '../services/settings_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceService = Provider.of<DeviceService>(context);
    final settingsService = Provider.of<SettingsService>(context);
    final data = deviceService.history;
    final unit = settingsService.temperatureUnit;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
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
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final reading = data[index];
                final temp = reading['temperature'] as double;
                final humidity = reading['humidity'];
                final timestamp = reading['timestamp'] as DateTime;
                
                return ListTile(
                  title: Text('${temp.toStringAsFixed(1)}$unit / $humidity%'),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(timestamp)),
                  leading: const Icon(Icons.thermostat_outlined, color: Colors.orange),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}