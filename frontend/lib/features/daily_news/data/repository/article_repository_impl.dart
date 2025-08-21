import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._newsApiService,this._appDatabase);
  
  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
   try {
    final query = await FirebaseFirestore.instance
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();

    final List<ArticleModel> list = query.docs.map((doc) {
      final data = doc.data();
      final thumb = (data['thumbnailURL'] ?? '') as String;
      final content = (data['content'] ?? '') as String;
      final title = (data['title'] ?? '') as String;
      final ts = data['publishedAt'];
      String publishedAt = '';
      if (ts is Timestamp) {
        publishedAt = ts.toDate().toIso8601String();
      } else if (ts != null) {
        publishedAt = ts.toString();
      }
      return ArticleModel(
        author: '',
        title: title,
        description: content,
        url: '',
        urlToImage: thumb.isNotEmpty ? thumb : kDefaultImage,
        publishedAt: publishedAt,
        content: content,
      );
    }).toList();

    return DataSuccess(list);
   } catch (e) {
    return DataFailed(
      DioException(requestOptions: RequestOptions(path: '/firestore'), error: e),
    );
   }
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }
  
}