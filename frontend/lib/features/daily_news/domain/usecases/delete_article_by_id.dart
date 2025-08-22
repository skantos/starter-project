import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class DeleteArticleByIdUseCase implements UseCase<DataState<void>, String> {
  final ArticleRepository _repo;
  DeleteArticleByIdUseCase(this._repo);

  @override
  Future<DataState<void>> call({String? params}) {
    return _repo.deleteArticleById(params ?? '');
  }
}


