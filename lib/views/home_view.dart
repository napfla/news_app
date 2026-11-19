import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NewsApiService _service = NewsApiService();

    static const Map<String, String> _categories = {
    'pendidikan': 'Pendidikan',
    'beasiswa': 'Beasiswa',
    'kampus OR universitas': 'Kampus',
    'sekolah': 'Sekolah',
    'guru': 'Guru',
    'kurikulum': 'Kurikulum',
    'UTBK OR SNBT': 'UTBK',
  };

  String _selectedCategory = 'pendidikan';

  late Future<List<ArticleModel>> _futureNews;

  @override
  void initState() {
    super.initState();
    _futureNews = _service.searchNews(_selectedCategory);
  }

  void _muatUlang() {
    setState(() {
      _futureNews = _service.searchNews(_selectedCategory);
    });
  }

  void _gantiKategori(String category) {
    if (category == _selectedCategory) return;
    _selectedCategory = category;
    _muatUlang();
  }

  Future<void> _onRefresh() async {
    _muatUlang();
    try {
      await _futureNews;
    } catch (_) {
      // error sudah ditampilkan oleh FutureBuilder
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edu News ID'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildCategoryChips(),
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: _futureNews,
              builder: (context, snapshot) {
                // State 1: LOADING
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                // State 2: ERROR
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _muatUlang,
                  );
                }

                // State 3: KOSONG
                final articles = snapshot.data ?? [];
                if (articles.isEmpty) {
                  return const Center(
                    child: Text('Belum ada berita untuk kategori ini.'),
                  );
                }

                // State 4: DATA
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ArticleCard(
                        article: article,
                        onTap: () =>
                            Get.toNamed(AppRoutes.detail, arguments: article),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
    Widget _buildCategoryChips() {
    return Container(
      height: 56,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories.keys.elementAt(index);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ChoiceChip(
              label: Text(_categories[category]!),
              selected: category == _selectedCategory,
              onSelected: (_) => _gantiKategori(category),
            ),
          );
        },
      ),
    );
  }
}