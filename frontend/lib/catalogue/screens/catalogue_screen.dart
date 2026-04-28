import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../models/models.dart';
import '../../services/api_service.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  final _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  String? _selectedCategoryId;
  bool _isGridView = true;
  String _sortBy = 'recent'; // 'recent' or 'alphabetical'
  
  late Future<List<Category>> _categoriesFuture;
  late Future<List<PdfDocument>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _api.getCategories();
    _documentsFuture = _api.searchPdfs();
  }

  void _search() {
    setState(() {
      _documentsFuture = _api.searchPdfs(
        query: _searchController.text,
        categoryId: _selectedCategoryId,
        sort: _sortBy,
      );
    });
  }

  void _cycleSort() {
    setState(() {
      if (_sortBy == 'recent') {
        _sortBy = 'popular';
      } else if (_sortBy == 'popular') {
        _sortBy = 'alphabetical';
      } else {
        _sortBy = 'recent';
      }
      _search();
    });
  }

  IconData _getSortIcon() {
    if (_sortBy == 'recent') return Symbols.schedule;
    if (_sortBy == 'popular') return Symbols.trending_up;
    return Symbols.sort_by_alpha;
  }

  String _getSortLabel() {
    if (_sortBy == 'recent') return 'Recent';
    if (_sortBy == 'popular') return 'Popular';
    return 'A-Z';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo1.png'),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A0E0C),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search books, authors, or topics...',
                prefixIcon: const Icon(Symbols.search, color: Color(0xFFFF3D1B)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFFF3D1B), width: 2),
                ),
              ),
            ),
          ),

          // Categories
          FutureBuilder<List<Category>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];
              return SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final category = isAll ? null : categories[index - 1];
                    final isSelected = isAll ? _selectedCategoryId == null : _selectedCategoryId == category?.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(isAll ? 'All' : category!.name),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = isAll ? null : category!.id;
                            _search();
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFFFF3D1B).withValues(alpha: 0.1),
                        checkmarkColor: const Color(0xFFFF3D1B),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFFFF3D1B) : const Color(0xFF64748B),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFFF3D1B) : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Sort & Display Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                ActionChip(
                  avatar: Icon(_getSortIcon(), size: 16, color: const Color(0xFF1A0E0C)),
                  label: Text(_getSortLabel()),
                  onPressed: _cycleSort,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _isGridView = true),
                        icon: Icon(Symbols.grid_view, 
                              color: _isGridView ? const Color(0xFFFF3D1B) : const Color(0xFF94A3B8), 
                              size: 20,
                              fill: _isGridView ? 1 : 0),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                      Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                      IconButton(
                        onPressed: () => setState(() => _isGridView = false),
                        icon: Icon(Symbols.list, 
                              color: !_isGridView ? const Color(0xFFFF3D1B) : const Color(0xFF94A3B8), 
                              size: 20,
                              fill: !_isGridView ? 1 : 0),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Books Section
          Expanded(
            child: FutureBuilder<List<PdfDocument>>(
              future: _documentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data ?? [];

                if (docs.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async => _search(),
                  child: _isGridView ? _buildGridView(docs) : _buildTableView(docs),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/Research paper-pana.svg',
              height: 200,
            ),
            const SizedBox(height: 24),
            const Text(
              'No documents found',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A0E0C)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Try adjusting your search or filters to find what you are looking for.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<PdfDocument> docs) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) => _BookGridItem(doc: docs[index]),
    );
  }

  Widget _buildTableView(List<PdfDocument> docs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: docs.length,
      itemBuilder: (context, index) => _BookTableItem(doc: docs[index]),
    );
  }
}

class _BookGridItem extends StatelessWidget {
  final PdfDocument doc;
  const _BookGridItem({required this.doc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/document/${doc.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/Research paper-amico.svg',
                      height: 100,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Text(
                        doc.categoryName ?? 'General',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            doc.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A0E0C)),
          ),
          const SizedBox(height: 4),
          Text(
            doc.author ?? 'Unknown',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BookTableItem extends StatelessWidget {
  final PdfDocument doc;
  const _BookTableItem({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Symbols.menu_book, color: Color(0xFFFF3D1B), size: 20),
        ),
        title: Text(
          doc.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text('${doc.author ?? 'Unknown'} · ${doc.categoryName ?? 'General'}', style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Symbols.chevron_right, color: Color(0xFF94A3B8)),
        onTap: () => context.push('/document/${doc.id}'),
      ),
    );
  }
}
