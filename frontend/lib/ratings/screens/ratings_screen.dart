import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../widgets/review_card.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  final _documentId = TextEditingController();
  final _comment = TextEditingController();
  double _rating = 4;
  String _activeDocumentId = '';

  @override
  Widget build(BuildContext context) {
    final future = _activeDocumentId.isEmpty ? Future.value(const []) : ApiService().getReviews(_activeDocumentId);
    return Scaffold(
      appBar: AppBar(title: const Text('Ratings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _documentId, decoration: const InputDecoration(labelText: 'Document ID')),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => setState(() => _activeDocumentId = _documentId.text),
            child: const Text('Load reviews'),
          ),
          const SizedBox(height: 16),
          if (_activeDocumentId.isNotEmpty) ...[
            Slider(value: _rating, min: 1, max: 5, divisions: 4, label: _rating.round().toString(), onChanged: (value) => setState(() => _rating = value)),
            TextField(controller: _comment, maxLines: 3, decoration: const InputDecoration(labelText: 'Leave a review')),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                await ApiService().submitReview({
                  'document_id': _activeDocumentId,
                  'user_name': 'Student reviewer',
                  'rating': _rating.round(),
                  'comment': _comment.text,
                });
                setState(() {});
              },
              child: const Text('Submit review'),
            ),
            const SizedBox(height: 16),
          ],
          FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              final reviews = snapshot.data ?? const [];
              return Column(children: reviews.map((review) => ReviewCard(review: review)).toList());
            },
          ),
        ],
      ),
    );
  }
}
