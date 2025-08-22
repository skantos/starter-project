import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_repository.dart';

class GetUserNameUseCase implements UseCase<DataState<String>, String> {
  final UserRepository _repo;
  GetUserNameUseCase(this._repo);

  @override
  Future<DataState<String>> call({String? params}) {
    return _repo.getUserName(params ?? '');
  }
}


