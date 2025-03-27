import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().signOut(),
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('device').doc('latest').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            children: [
              _buildMetricCard('Temperature', '${data['temperature']}°C'),
              _buildMetricCard('Humidity', '${data['humidity']}%'),
              _buildThresholdStatus(data['threshold']),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/threshold'),
                child: Text('Configure Threshold'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/history'),
                child: Text('View History'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _buildThresholdStatus(double threshold) {
    return Chip(
      label: Text('Current Threshold: $threshold°C'),
      backgroundColor: Colors.orangeAccent,
    );
  }
}