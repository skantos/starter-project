import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetFavoritesCountUseCase implements UseCase<DataState<int>, String?> {
  final ArticleRepository _repo;
  GetFavoritesCountUseCase(this._repo);

  @override
  Future<DataState<int>> call({String? params}) {
    return _repo.getFavoritesCount(userId: params);
  }
}


