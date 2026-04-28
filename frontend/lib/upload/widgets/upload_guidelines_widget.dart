import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class UploadGuidelinesWidget extends StatelessWidget {
  const UploadGuidelinesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      'Use a descriptive title and include the course code.',
      'Add enough metadata for search and moderation.',
      'Only upload material you are allowed to share.',
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submission guide', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Symbols.check_circle, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
