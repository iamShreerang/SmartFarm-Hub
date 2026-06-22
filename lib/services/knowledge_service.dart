import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/knowledge.dart';

class KnowledgeService {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference get _articles => _firestore.collection('knowledge');

  Stream<List<KnowledgeArticle>> watchArticles({ArticleCategory? category}) {
    Query query = _articles.orderBy('publishedAt', descending: true);
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    return query
        .limit(20)
        .snapshots()
        .map((s) => s.docs.map(KnowledgeArticle.fromFirestore).toList());
  }

  Future<KnowledgeArticle?> getArticle(String id) async {
    final doc = await _articles.doc(id).get();
    if (!doc.exists) return null;
    return KnowledgeArticle.fromFirestore(doc);
  }

  /// Seeds initial articles into Firestore (run once)
  Future<void> seedArticles() async {
    final existing = await _articles.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final articles = [
      {
        'title': 'Tomato Growing Complete Guide',
        'summary': 'Everything you need to know about growing tomatoes successfully.',
        'content': 'Tomatoes thrive in full sun with 6-8 hours daily. Plant after last frost...',
        'category': 'cropGuide',
        'tags': ['tomato', 'vegetables', 'beginner'],
        'publishedAt': Timestamp.now(),
      },
      {
        'title': 'NPK Fertilizer Guide for Farmers',
        'summary': 'Understanding nitrogen, phosphorus, and potassium for healthy crops.',
        'content': 'NPK stands for Nitrogen (N), Phosphorus (P), and Potassium (K)...',
        'category': 'fertilizer',
        'tags': ['fertilizer', 'soil', 'nutrition'],
        'publishedAt': Timestamp.now(),
      },
      {
        'title': 'Integrated Pest Management (IPM)',
        'summary': 'Eco-friendly strategies to manage pests without harming the environment.',
        'content': 'IPM combines biological, cultural, physical, and chemical tools...',
        'category': 'pestManagement',
        'tags': ['pest', 'organic', 'IPM'],
        'publishedAt': Timestamp.now(),
      },
      {
        'title': 'Kharif Season Farming Guide',
        'summary': 'Best crops and practices for the monsoon farming season.',
        'content': 'Kharif crops are sown in June-July and harvested in September-October...',
        'category': 'seasonal',
        'tags': ['kharif', 'monsoon', 'seasonal'],
        'publishedAt': Timestamp.now(),
      },
    ];

    final batch = _firestore.batch();
    for (final article in articles) {
      batch.set(_articles.doc(), article);
    }
    await batch.commit();
  }
}
