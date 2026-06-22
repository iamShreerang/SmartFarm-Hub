import 'package:flutter/material.dart';
import '../../models/knowledge.dart';
import '../../services/knowledge_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final _knowledgeService = KnowledgeService();
  ArticleCategory? _selectedCategory;

  static const _categories = <ArticleCategory?, String>{
    null: 'All',
    ArticleCategory.cropGuide: 'Crop Guides',
    ArticleCategory.fertilizer: 'Fertilizers',
    ArticleCategory.pestManagement: 'Pest Control',
    ArticleCategory.seasonal: 'Seasonal',
  };

  @override
  void initState() {
    super.initState();
    _knowledgeService.seedArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Center')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: _categories.entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(e.value),
                          selected: _selectedCategory == e.key,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                              color: _selectedCategory == e.key
                                  ? Colors.white
                                  : AppColors.textDark),
                          onSelected: (_) =>
                              setState(() => _selectedCategory = e.key),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<KnowledgeArticle>>(
              stream: _knowledgeService.watchArticles(
                  category: _selectedCategory),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ErrorView(message: snapshot.error.toString());
                }
                final articles = snapshot.data ?? [];
                if (articles.isEmpty) {
                  return const EmptyState(
                    title: 'No Articles Yet',
                    subtitle: 'Articles will appear here as they are added.',
                    icon: Icons.article,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: articles.length,
                  itemBuilder: (_, i) =>
                      _ArticleCard(article: articles[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final KnowledgeArticle article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    _ArticleDetailScreen(article: article))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _categoryColor(article.category).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_categoryIcon(article.category),
                    color: _categoryColor(article.category), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryBadge(category: article.category),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.summary,
                      style: TextStyle(
                          color: AppColors.textGrey, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(ArticleCategory cat) {
    switch (cat) {
      case ArticleCategory.cropGuide:
        return AppColors.primary;
      case ArticleCategory.fertilizer:
        return AppColors.accent;
      case ArticleCategory.pestManagement:
        return AppColors.error;
      case ArticleCategory.seasonal:
        return AppColors.info;
      default:
        return AppColors.textGrey;
    }
  }

  IconData _categoryIcon(ArticleCategory cat) {
    switch (cat) {
      case ArticleCategory.cropGuide:
        return Icons.grass;
      case ArticleCategory.fertilizer:
        return Icons.science;
      case ArticleCategory.pestManagement:
        return Icons.bug_report;
      case ArticleCategory.seasonal:
        return Icons.calendar_month;
      default:
        return Icons.article;
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final ArticleCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.name,
        style: const TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ArticleDetailScreen extends StatelessWidget {
  final KnowledgeArticle article;
  const _ArticleDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(article.imageUrl!,
                    height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text(article.title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(article.summary,
                style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 15,
                    fontStyle: FontStyle.italic)),
            const Divider(height: 24),
            Text(article.content,
                style: const TextStyle(height: 1.7, fontSize: 15)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
