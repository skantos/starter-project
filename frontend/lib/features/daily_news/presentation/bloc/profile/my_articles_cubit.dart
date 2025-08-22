import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles_by_author.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article_by_id.dart';

abstract class MyArticlesState {
  const MyArticlesState();
}

class MyArticlesLoading extends MyArticlesState { const MyArticlesLoading(); }
class MyArticlesLoaded extends MyArticlesState { final List<ArticleEntity> articles; const MyArticlesLoaded(this.articles); }
class MyArticlesError extends MyArticlesState { final String message; const MyArticlesError(this.message); }

class MyArticlesCubit extends Cubit<MyArticlesState> {
  final GetArticlesByAuthorUseCase _get;
  final DeleteArticleByIdUseCase _delete;
  MyArticlesCubit(this._get, this._delete) : super(const MyArticlesLoading());

  Future<void> load(String authorId) async {
    emit(const MyArticlesLoading());
    final res = await _get(params: authorId);
    if (res is DataSuccess<List<ArticleEntity>>) {
      emit(MyArticlesLoaded(res.data ?? const []));
    } else {
      emit(MyArticlesError(res.error?.message ?? 'Error'));
    }
  }

  Future<void> delete(String id, String authorId) async {
    await _delete(params: id);
    await load(authorId);
  }
}


