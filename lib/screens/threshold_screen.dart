import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThresholdScreen extends StatefulWidget {
  const ThresholdScreen({super.key});

  @override
  ThresholdScreenState createState() => ThresholdScreenState();
}

class ThresholdScreenState extends State<ThresholdScreen> {
  final _formKey = GlobalKey<FormState>();
  double _threshold = 25.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Threshold')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Slider(
                min: 0,
                max: 50,
                value: _threshold,
                onChanged: (value) => setState(() => _threshold = value),
                divisions: 50,
                label: '${_threshold.round()}°C',
              ),
              ElevatedButton(
                onPressed: () async {
                  final context = this.context;
                  await FirebaseFirestore.instance
                      .collection('config')
                      .doc('threshold')
                      .set({'value': _threshold});
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: Text('Save Threshold'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}