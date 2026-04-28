import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  late Future<HomePayload> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getHomePayload();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final username = auth.displayName.isNotEmpty ? auth.displayName.split(' ').first : 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FutureBuilder<HomePayload>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data;

            return RefreshIndicator(
              onRefresh: () async => setState(() => _future = _api.getHomePayload()),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  // Top Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/logo1.png', height: 32),
                            const SizedBox(height: 16),
                            Text(
                              'Hello, $username',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A0E0C),
                              ),
                            ),
                            const Text(
                              'Find your learning materials',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                            ),
                          ],
                        ),
                        _NotificationIcon(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Slideshow
                  _FeatureSlideshow(),
                  const SizedBox(height: 32),

                  // Recent Uploads
                  _SectionHeader(
                    title: 'Recent Upload',
                    onViewAll: () => context.push('/catalogue'),
                  ),
                  const SizedBox(height: 16),
                  _RecentUploadsList(books: data?.recent ?? []),
                  const SizedBox(height: 32),

                  // Categories
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A0E0C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CategoriesGrid(),
                  const SizedBox(height: 32),

                  // Continue Reading
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Continue Reading',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A0E0C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ContinueReadingList(books: data?.continueReading ?? []),
                  
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Stack(
        children: [
          Icon(Symbols.notifications, color: Color(0xFF1A0E0C), size: 26),
          Positioned(
            right: 2,
            top: 2,
            child: CircleAvatar(
              radius: 4,
              backgroundColor: Color(0xFFFF3D1B),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureSlideshow extends StatelessWidget {
  final List<Map<String, String>> features = [
    {
      'title': 'Access Saved Books',
      'desc': 'Keep your favorite resources handy for offline reading.',
      'image': 'assets/images/Bibliophile-bro.svg',
      'cta': 'View Library',
    },
    {
      'title': 'Search for a Book',
      'desc': 'Find exactly what you need in seconds with our smart search.',
      'image': 'assets/images/Google sitemap-bro.svg',
      'cta': 'Search Now',
    },
    {
      'title': 'Study Collaborative',
      'desc': 'Share resources and study with your fellow students.',
      'image': 'assets/images/Collab-bro.svg',
      'cta': 'Explore',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        autoPlay: true,
      ),
      items: features.map((f) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3D1B), Color(0xFFFF6B4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Opacity(
                      opacity: 0.2,
                      child: SvgPicture.asset(f['image']!, height: 160),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          f['title']!,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 180,
                          child: Text(
                            f['desc']!,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (f['cta'] == 'Search Now') {
                              context.push('/search');
                            } else {
                              context.push('/catalogue');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFFF3D1B),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(f['cta']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A0E0C)),
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All', style: TextStyle(color: Color(0xFFFF3D1B), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _RecentUploadsList extends StatelessWidget {
  final List<PdfDocument> books;

  const _RecentUploadsList({required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/images/Research paper-pana.svg',
                height: 120,
              ),
              const SizedBox(height: 16),
              const Text(
                'No recent uploads yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A0E0C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Be the first to share learning materials with your fellow students!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/upload'),
                  icon: const Icon(Symbols.upload, size: 20),
                  label: const Text('Start Uploading', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3D1B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: books.take(5).length,
        itemBuilder: (context, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () => context.push('/document/${book.id}'),
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 5),
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
                              fit: BoxFit.contain,
                              height: 100,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Symbols.bookmark, size: 16, color: Color(0xFFFF3D1B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    book.categoryName ?? 'General',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Lecture Notes', 'icon': Symbols.description, 'color': Color(0xFFFFF5F4), 'textColor': Color(0xFFFF3D1B)},
    {'name': 'Past Exam Papers', 'icon': Symbols.history_edu, 'color': Color(0xFFFFF7ED), 'textColor': Color(0xFFEA580C)},
    {'name': 'Tutorials & Assignments', 'icon': Symbols.assignment, 'color': Color(0xFFF0FDF4), 'textColor': Color(0xFF16A34A)},
    {'name': 'Practical Guides', 'icon': Symbols.build, 'color': Color(0xFFFEF2F2), 'textColor': Color(0xFFDC2626)},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final c = categories[index];
          return Container(
            decoration: BoxDecoration(
              color: c['color'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => context.push('/catalogue'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(c['icon'], color: c['textColor'], size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c['name'],
                        style: TextStyle(
                          color: c['textColor'],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ContinueReadingList extends StatelessWidget {
  final List<PdfDocument> books;

  const _ContinueReadingList({required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/images/Bibliophile-bro.svg',
                height: 120,
              ),
              const SizedBox(height: 16),
              const Text(
                'Start your reading journey',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A0E0C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Browse through thousands of documents and pick up where you left off.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/catalogue'),
                  icon: const Icon(Symbols.explore, size: 20),
                  label: const Text('Browse Catalogue', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF3D1B),
                    side: const BorderSide(color: Color(0xFFFF3D1B), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final progress = book.readingProgress ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Symbols.menu_book, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}% completed',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF3D1B)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => context.push('/reader', extra: {'url': book.fileUrl, 'title': book.title, 'documentId': book.id}),
                icon: const Icon(Symbols.play_circle, color: Color(0xFFFF3D1B), size: 32),
              ),
            ],
          ),
        );
      },
    );
  }
}
