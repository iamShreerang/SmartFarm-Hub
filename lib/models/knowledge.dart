import 'package:cloud_firestore/cloud_firestore.dart';

enum ArticleCategory { cropGuide, fertilizer, pestManagement, seasonal, general }

class KnowledgeArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final ArticleCategory category;
  final String? imageUrl;
  final List<String> tags;
  final DateTime publishedAt;

  KnowledgeArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    this.imageUrl,
    this.tags = const [],
    required this.publishedAt,
  });

  factory KnowledgeArticle.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return KnowledgeArticle(
      id: doc.id,
      title: d['title'] ?? '',
      summary: d['summary'] ?? '',
      content: d['content'] ?? '',
      category: ArticleCategory.values.firstWhere(
        (e) => e.name == d['category'],
        orElse: () => ArticleCategory.general,
      ),
      imageUrl: d['imageUrl'],
      tags: List<String>.from(d['tags'] ?? []),
      publishedAt: (d['publishedAt'] as Timestamp).toDate(),
    );
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}
