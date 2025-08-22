import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/is_article_saved.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';

class FavoriteState {
  final bool isSaved;
  final bool loading;
  const FavoriteState({required this.isSaved, required this.loading});
  FavoriteState copyWith({bool? isSaved, bool? loading}) => FavoriteState(isSaved: isSaved ?? this.isSaved, loading: loading ?? this.loading);
}

class FavoriteCubit extends Cubit<FavoriteState> {
  final IsArticleSavedUseCase _isSaved;
  final SaveArticleUseCase _save;
  final RemoveArticleUseCase _remove;
  FavoriteCubit(this._isSaved, this._save, this._remove) : super(const FavoriteState(isSaved: false, loading: false));

  Future<void> check(String articleId) async {
    emit(state.copyWith(loading: true));
    final res = await _isSaved(params: articleId);
    emit(FavoriteState(isSaved: (res is DataSuccess<bool>) ? (res.data ?? false) : false, loading: false));
  }

  Future<void> toggle(ArticleEntity article) async {
    emit(state.copyWith(loading: true));
    if (state.isSaved) {
      await _remove(params: article);
      emit(state.copyWith(isSaved: false, loading: false));
    } else {
      await _save(params: article);
      emit(state.copyWith(isSaved: true, loading: false));
    }
  }
}


