class Category {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  final int resourceCount;

  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.resourceCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      resourceCount: json['resource_count'] as int? ?? 0,
    );
  }
}

class PdfDocument {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final String fileUrl;
  final int? fileSize;
  final String? author;
  final String? year;
  final List<String> tags;
  final int views;
  final int downloads;
  final String? categoryName;
  final double rating;
  final int reviewCount;
  final bool featured;
  final bool bookmarked;
  final double? readingProgress; // 0.0 to 1.0


  const PdfDocument({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.fileUrl,
    this.fileSize,
    this.author,
    this.year,
    this.tags = const [],
    this.views = 0,
    this.downloads = 0,
    this.categoryName,
    this.rating = 0,
    this.reviewCount = 0,
    this.featured = false,
    this.bookmarked = false,
    this.readingProgress,
  });

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'];
    return PdfDocument(
      id: json['id'].toString(),
      title: json['title'] as String? ?? 'Untitled resource',
      description: json['description'] as String?,
      categoryId: json['category_id']?.toString() ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      fileSize: json['file_size'] as int?,
      author: json['author'] as String?,
      year: json['year']?.toString(),
      tags: (json['tags'] as List<dynamic>? ?? const []).map((tag) => tag.toString()).toList(),
      views: json['views'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      categoryName: categories is Map<String, dynamic> ? categories['name'] as String? : json['category_name'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      featured: json['featured'] as bool? ?? false,
      bookmarked: json['bookmarked'] as bool? ?? false,
      readingProgress: (json['reading_progress'] as num?)?.toDouble(),
    );
  }
}

class HomePayload {
  final List<PdfDocument> featured;
  final List<PdfDocument> trending;
  final List<PdfDocument> recent;
  final List<Category> categories;
  final List<PdfDocument> continueReading;


  const HomePayload({
    required this.featured,
    required this.trending,
    required this.recent,
    required this.categories,
    required this.continueReading,
  });

  factory HomePayload.fromJson(Map<String, dynamic> json) {
    List<PdfDocument> docs(dynamic raw) => (raw as List<dynamic>? ?? const [])
        .map((item) => PdfDocument.fromJson(item as Map<String, dynamic>))
        .toList();

    final categories = (json['categories'] as List<dynamic>? ?? const [])
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();

    return HomePayload(
      featured: docs(json['featured']),
      trending: docs(json['trending']),
      recent: docs(json['recent']),
      categories: categories,
      continueReading: docs(json['continue_reading']),
    );
  }
}

class SearchPayload {
  final List<PdfDocument> results;
  final List<String> suggestions;
  final List<Category> categories;

  const SearchPayload({
    required this.results,
    required this.suggestions,
    required this.categories,
  });

  factory SearchPayload.fromJson(Map<String, dynamic> json) {
    return SearchPayload(
      results: (json['results'] as List<dynamic>? ?? const [])
          .map((item) => PdfDocument.fromJson(item as Map<String, dynamic>))
          .toList(),
      suggestions: (json['suggestions'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BookmarkItem {
  final String id;
  final String userId;
  final String pdfId;
  final PdfDocument document;

  const BookmarkItem({
    required this.id,
    required this.userId,
    required this.pdfId,
    required this.document,
  });

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    final pdf = (json['pdfs'] ?? json['document']) as Map<String, dynamic>;
    return BookmarkItem(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      pdfId: json['pdf_id'].toString(),
      document: PdfDocument.fromJson(pdf),
    );
  }
}

class Review {
  final String id;
  final String documentId;
  final String userName;
  final int rating;
  final String comment;
  final String createdAt;

  const Review({
    required this.id,
    required this.documentId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      documentId: json['document_id'].toString(),
      userName: json['user_name'] as String? ?? 'Anonymous',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class AdminDashboardPayload {
  final Map<String, dynamic> summary;
  final List<PdfDocument> flaggedDocuments;
  final List<Map<String, dynamic>> recentUsers;

  const AdminDashboardPayload({
    required this.summary,
    required this.flaggedDocuments,
    required this.recentUsers,
  });

  factory AdminDashboardPayload.fromJson(Map<String, dynamic> json) {
    return AdminDashboardPayload(
      summary: Map<String, dynamic>.from(json['summary'] as Map? ?? const {}),
      flaggedDocuments: (json['flagged_documents'] as List<dynamic>? ?? const [])
          .map((item) => PdfDocument.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentUsers: (json['recent_users'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }
}

class Faculty {
  final String id;
  final String name;

  const Faculty({
    required this.id,
    required this.name,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
    );
  }
}

class Program {
  final String id;
  final String name;

  const Program({
    required this.id,
    required this.name,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
    );
  }
}
