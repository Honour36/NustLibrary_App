import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ReaderToolbar extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onBookmarks;

  const ReaderToolbar({
    super.key,
    required this.onDownload,
    required this.onBookmarks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: onDownload, icon: const Icon(Symbols.download)),
        IconButton(onPressed: onBookmarks, icon: const Icon(Symbols.bookmarks)),
      ],
    );
  }
}
