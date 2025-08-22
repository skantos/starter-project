import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class IsArticleSavedUseCase implements UseCase<DataState<bool>, String> {
  final ArticleRepository _repo;
  IsArticleSavedUseCase(this._repo);

  @override
  Future<DataState<bool>> call({String? params}) {
    return _repo.isArticleSaved(params ?? '');
  }
}


