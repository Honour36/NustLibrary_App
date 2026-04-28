import 'package:flutter/material.dart';

class DownloadManagerScreen extends StatelessWidget {
  const DownloadManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download manager')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: ListTile(
            title: Text('Queued downloads'),
            subtitle: Text('Downloads are tracked through the backend session feed.'),
          ),
        ),
      ),
    );
  }
}
