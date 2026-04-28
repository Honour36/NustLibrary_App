import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService().getAnalytics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final analytics = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: analytics.entries.map((entry) => Card(child: ListTile(title: Text(entry.key), subtitle: Text(entry.value.toString())))).toList(),
          );
        },
      ),
    );
  }
}
