import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../services/api_service.dart';

class ModerationQueueScreen extends StatelessWidget {
  const ModerationQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderation queue')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService().getModerationQueue(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: items
                .map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item['title']?.toString() ?? 'Untitled'),
                      subtitle: Text(item['status']?.toString() ?? 'pending'),
                      trailing: const Icon(Symbols.chevron_right),
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
