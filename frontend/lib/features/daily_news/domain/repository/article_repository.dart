import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  // API methods
  Future<DataState<List<ArticleEntity>>> getNewsArticles();

  // Database methods
  Future<DataState<List<ArticleEntity>>> getSavedArticles();

  Future<DataState<void>> saveArticle(ArticleEntity article);

  Future<DataState<void>> removeArticle(ArticleEntity article);

  // Favorites helpers
  Future<DataState<bool>> isArticleSaved(String articleId);
  Future<DataState<int>> getFavoritesCount({String? userId});
  Future<DataState<List<ArticleEntity>>> getArticlesByAuthor(String authorId);
  Future<DataState<void>> deleteArticleById(String id);
}