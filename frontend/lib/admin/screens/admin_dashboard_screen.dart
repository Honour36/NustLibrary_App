import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_service.dart';
import '../../models/models.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin dashboard')),
      body: FutureBuilder<AdminDashboardPayload>(
        future: ApiService().getAdminDashboard(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: data.summary.entries
                    .map((entry) => SizedBox(
                          width: 170,
                          child: Card(
                            child: ListTile(title: Text(entry.key), subtitle: Text(entry.value.toString())),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: () => context.push('/admin/documents'), child: const Text('Manage documents')),
              const SizedBox(height: 8),
              FilledButton.tonal(onPressed: () => context.push('/admin/users'), child: const Text('Manage users')),
              const SizedBox(height: 8),
              FilledButton.tonal(onPressed: () => context.push('/admin/analytics'), child: const Text('View analytics')),
            ],
          );
        },
      ),
    );
  }
}
