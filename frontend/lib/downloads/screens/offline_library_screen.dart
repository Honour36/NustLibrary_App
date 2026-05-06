import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class OfflineLibraryScreen extends StatefulWidget {
  const OfflineLibraryScreen({super.key});

  @override
  State<OfflineLibraryScreen> createState() => _OfflineLibraryScreenState();
}

class _OfflineLibraryScreenState extends State<OfflineLibraryScreen> {
  final _api = ApiService();

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().user?['id']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Saved Books', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A0E0C),
        elevation: 0,
        centerTitle: true,
      ),
      body: userId.isEmpty
          ? _buildEmptyState('Please log in to see your saved books')
          : FutureBuilder<List<BookmarkItem>>(
              future: _api.getBookmarks(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF3D1B)));
                }

                if (snapshot.hasError) {
                  return _buildEmptyState('Something went wrong. Please try again.');
                }

                final bookmarks = snapshot.data ?? [];

                if (bookmarks.isEmpty) {
                  return _buildEmptyState('You haven\'t saved any books yet.');
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    final doc = bookmark.document;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Symbols.description, color: Color(0xFFFF3D1B), size: 30),
                        ),
                        title: Text(
                          doc.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              doc.author ?? 'Anonymous',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Symbols.star, size: 14, color: Color(0xFFFFB800), fill: 1),
                                const SizedBox(width: 4),
                                Text(
                                  doc.rating.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Symbols.delete, color: Color(0xFF94A3B8), size: 22),
                          onPressed: () async {
                            await _api.toggleBookmark(userId, doc.id);
                            setState(() {}); // Refresh list
                          },
                        ),
                        onTap: () => context.push('/catalogue/${doc.id}'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3D1B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Symbols.bookmark_add, size: 64, color: Color(0xFFFF3D1B)),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/catalogue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3D1B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Browse Library', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
