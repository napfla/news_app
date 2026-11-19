import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final NewsApiService _service = NewsApiService();

  // Kata kunci dikirim dari HomeView lewat Get.arguments
  final String _keyword = Get.arguments as String;

  late Future<List<ArticleModel>> _futureResult;

  @override
  void initState() {
    super.initState();
    _futureResult = _service.searchNews(_keyword);
  }

  void _muatUlang() {
    setState(() {
      _futureResult = _service.searchNews(_keyword);
    });
  }

  Future<void> _onRefresh() async {
    _muatUlang();
    try {
      await _futureResult;
    } catch (_) {
      // error sudah ditampilkan oleh FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil: $_keyword'),
      ),
      body: FutureBuilder<List<ArticleModel>>(
        future: _futureResult,
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
            return Center(
              child: Text('Tidak ada berita untuk "$_keyword".'),
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
    );
  }
}