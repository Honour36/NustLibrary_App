import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/bookmark_panel.dart';
import '../widgets/reader_toolbar.dart';

class PdfReaderScreen extends StatefulWidget {
  final String url;
  final String title;
  final String? documentId;

  const PdfReaderScreen({
    super.key,
    required this.url,
    required this.title,
    this.documentId,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  String? _localPath;
  bool _loading = true;
  String? _error;
  final List<String> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // On web, we can't download to File — just show an open button
      setState(() => _loading = false);
    } else {
      _download();
    }
  }

  Future<void> _download() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/reader_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await Dio().download(widget.url, file.path);
      if (mounted) setState(() => _localPath = file.path);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the document.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFFFF3D1B),
        foregroundColor: Colors.white,
        actions: [
          if (!kIsWeb)
            ReaderToolbar(
              onDownload: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document cached for this session.')),
              ),
              onBookmarks: () => Scaffold.of(context).openEndDrawer(),
            ),
          IconButton(
            icon: const Icon(Symbols.open_in_new),
            tooltip: 'Open in browser',
            onPressed: _openInBrowser,
          ),
        ],
      ),
      endDrawer: BookmarkPanel(bookmarks: _bookmarks),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF3D1B)),
            SizedBox(height: 16),
            Text('Loading document...', style: TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    // On web — show a launch button since PDFView doesn't work in browser
    if (kIsWeb) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Symbols.picture_as_pdf, size: 64, color: Color(0xFFFF3D1B)),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A0E0C)),
              ),
              const SizedBox(height: 12),
              const Text(
                'PDF viewing in browser requires opening in a new tab.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _openInBrowser,
                  icon: const Icon(Symbols.open_in_new),
                  label: const Text('Open PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3D1B),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Native — show the PDF inline
    if (_error != null || _localPath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text('Unable to open PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Symbols.open_in_new),
              label: const Text('Open in browser instead'),
            ),
          ],
        ),
      );
    }

    return PDFView(
      filePath: _localPath!,
      onPageChanged: (page, total) {
        if (page != null && !_bookmarks.contains('Page ${page + 1}')) {
          _bookmarks.add('Page ${page + 1}');
        }
      },
    );
  }
}
