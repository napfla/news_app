import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NewsApiService _service = NewsApiService();

  // Key = kata kunci untuk API, value = label di chip
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

  /// Cache: kata kunci -> Future hasilnya
  final Map<String, Future<List<ArticleModel>>> _cache = {};

  /// Future disimpan di State, BUKAN dibuat di dalam build()
  late Future<List<ArticleModel>> _futureNews;

  /// Ambil dari cache, atau buat request baru kalau belum ada
  Future<List<ArticleModel>> _ambilDariCache(String keyword) {
    return _cache.putIfAbsent(keyword, () => _service.searchNews(keyword));
  }

  @override
  void initState() {
    super.initState();
    _futureNews = _ambilDariCache(_selectedCategory);
  }

  /// Dipakai tombol Coba Lagi & pull-to-refresh: paksa request baru
  void _muatUlang() {
    setState(() {
      _cache.remove(_selectedCategory);
      _futureNews = _ambilDariCache(_selectedCategory);
    });
  }

  /// Dipakai chip: pakai cache kalau ada
  void _gantiKategori(String category) {
    if (category == _selectedCategory) return;
    setState(() {
      _selectedCategory = category;
      _futureNews = _ambilDariCache(category);
    });
  }

  Future<void> _onRefresh() async {
    _muatUlang();
    try {
      await _futureNews;
    } catch (_) {
      // error sudah ditampilkan oleh FutureBuilder
    }
  }

  Future<void> _bukaDialogCari() async {
    final controller = TextEditingController();

    final keyword = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari Berita'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Kata kunci...'),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Cari'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (keyword != null && keyword.isNotEmpty) {
      Get.toNamed(AppRoutes.search, arguments: keyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lensa Pendidikan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _bukaDialogCari,
          ),
        ],
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
                    child: Text('Belum ada berita untuk topik ini.'),
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
    return SizedBox(
      height: 56,
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
              showCheckmark: false,
              onSelected: (_) => _gantiKategori(category),
            ),
          );
        },
      ),
    );
  }
}