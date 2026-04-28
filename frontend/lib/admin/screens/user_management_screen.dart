import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User management')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService().getAdminUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!
                .map((user) => Card(child: ListTile(title: Text(user['name']?.toString() ?? 'User'), subtitle: Text(user['email']?.toString() ?? ''))))
                .toList(),
          );
        },
      ),
    );
  }
}
