import 'package:flutter/material.dart';

class FlagDialog extends StatefulWidget {
  const FlagDialog({super.key});

  @override
  State<FlagDialog> createState() => _FlagDialogState();
}

class _FlagDialogState extends State<FlagDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Flag document'),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        decoration: const InputDecoration(hintText: 'Describe the issue'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(_controller.text), child: const Text('Submit')),
      ],
    );
  }
}
