import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_repository.dart';

class GetCurrentUserIdUseCase implements UseCase<DataState<String?>, void> {
  final UserRepository _repo;
  GetCurrentUserIdUseCase(this._repo);

  @override
  Future<DataState<String?>> call({void params}) {
    return _repo.getCurrentUserId();
  }
}


