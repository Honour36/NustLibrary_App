import 'package:flutter/material.dart';

import '../../models/models.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${review.rating}/5'),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            const SizedBox(height: 8),
            Text(review.createdAt, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
