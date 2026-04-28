import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../services/api_service.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/search_bar_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _api = ApiService();
  final _controller = TextEditingController();
  String? _categoryId;
  late Future<SearchPayload> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getSearchPayload();
  }

  void _load() {
    setState(() {
      _future = _api.getSearchPayload(query: _controller.text, categoryId: _categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: FutureBuilder<SearchPayload>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SearchBarWidget(controller: _controller, onSubmitted: (_) => _load()),
              const SizedBox(height: 12),
              FilterChipsRow(categories: data.categories, selectedCategoryId: _categoryId, onSelected: (value) {
                _categoryId = value;
                _load();
              }),
              const SizedBox(height: 12),
              if (data.suggestions.isNotEmpty) Wrap(spacing: 8, children: data.suggestions.map((item) => ActionChip(label: Text(item), onPressed: () {
                    _controller.text = item;
                    _load();
                  })).toList()),
              const SizedBox(height: 12),
              ...data.results.map((doc) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text(doc.title),
                      subtitle: Text('${doc.author ?? 'Unknown'} • ${doc.categoryName ?? 'General'}'),
                      onTap: () => context.push('/document/${doc.id}'),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
