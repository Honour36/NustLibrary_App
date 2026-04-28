import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      hintText: 'Search title, author, subject',
      leading: const Icon(Symbols.search),
      onSubmitted: onSubmitted,
    );
  }
}
