import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/models.dart';

class MyUploadsScreen extends StatelessWidget {
  const MyUploadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().user?['id']?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('My uploads')),
      body: FutureBuilder<List<PdfDocument>>(
        future: ApiService().getUserUploads(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) => Card(child: ListTile(title: Text(doc.title), subtitle: Text(doc.categoryName ?? 'Pending category')))).toList(),
          );
        },
      ),
    );
  }
}
