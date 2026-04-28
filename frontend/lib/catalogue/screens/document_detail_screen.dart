import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class DocumentDetailScreen extends StatefulWidget {
  final String id;

  const DocumentDetailScreen({super.key, required this.id});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  final _api = ApiService();
  late Future<PdfDocument> _future;
  int _userRating = 0;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _future = _api.getPdfDetails(widget.id);
    _checkSavedState();
  }

  Future<void> _checkSavedState() async {
    final userId = context.read<AuthService>().user?['id']?.toString() ?? '';
    if (userId.isEmpty) return;
    final saved = await _api.checkBookmark(userId, widget.id);
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleSave() async {
    final userId = context.read<AuthService>().user?['id']?.toString() ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save books')),
      );
      return;
    }
    
    // Optimistic update
    setState(() => _isSaved = !_isSaved);
    try {
      final saved = await _api.toggleBookmark(userId, widget.id);
      if (mounted) {
        setState(() => _isSaved = saved);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saved ? 'Saved to bookmarks' : 'Removed from bookmarks'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: saved ? const Color(0xFFFF3D1B) : const Color(0xFF64748B),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert on error
      if (mounted) setState(() => _isSaved = !_isSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Book Preview', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A0E0C),
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Symbols.bookmark : Symbols.bookmark_add, 
                  fill: _isSaved ? 1 : 0, 
                  color: _isSaved ? const Color(0xFFFF3D1B) : const Color(0xFF1A0E0C)),
            onPressed: _toggleSave,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<PdfDocument>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load book details'));
          }

          final doc = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section: Image Preview
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Center(
                    child: Hero(
                      tag: 'doc-${doc.id}',
                      child: SvgPicture.asset(
                        'assets/images/Research paper-amico.svg',
                        height: 200,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Info
                      Text(
                        doc.title,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A0E0C)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Symbols.person, size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(
                            'Uploaded by ${doc.author ?? 'Anonymous'}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3D1B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              doc.categoryName ?? 'General',
                              style: const TextStyle(color: Color(0xFFFF3D1B), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Rating Section
                      const Text(
                        'Rate this resource',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A0E0C)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return GestureDetector(
                            onTap: () => setState(() => _userRating = starIndex),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                starIndex <= _userRating ? Symbols.star : Symbols.star_outline,
                                fill: starIndex <= _userRating ? 1 : 0,
                                color: starIndex <= _userRating ? const Color(0xFFFFB800) : const Color(0xFFE2E8F0),
                                size: 32,
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              onPressed: () => context.push('/reader', extra: {
                                'url': doc.fileUrl, 
                                'title': doc.title, 
                                'documentId': doc.id
                              }),
                              icon: const Icon(Symbols.menu_book),
                              label: const Text('Read Now', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFF3D1B),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _toggleSave,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF3D1B),
                                side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Icon(_isSaved ? Symbols.bookmark_added : Symbols.bookmark_add, 
                                    fill: _isSaved ? 1 : 0, size: 24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
