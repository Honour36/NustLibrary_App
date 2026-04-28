import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../models/models.dart';

class DocumentManagementScreen extends StatelessWidget {
  const DocumentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document management')),
      body: FutureBuilder<List<PdfDocument>>(
        future: ApiService().getAdminDocuments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!
                .map((doc) => Card(child: ListTile(title: Text(doc.title), subtitle: Text('${doc.views} views · ${doc.downloads} downloads'))))
                .toList(),
          );
        },
      ),
    );
  }
}
