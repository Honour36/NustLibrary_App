import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class OfflineLibraryScreen extends StatelessWidget {
  const OfflineLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().user?['id']?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Offline library')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService().getDownloads(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: items
                .map(
                  (item) => Card(
                    child: ListTile(
                      leading: const Icon(Symbols.download_done),
                      title: Text(item['title']?.toString() ?? 'Document'),
                      subtitle: Text(item['status']?.toString() ?? 'available offline'),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
