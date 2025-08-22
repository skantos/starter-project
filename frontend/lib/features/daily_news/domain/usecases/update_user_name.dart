import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_repository.dart';

class UpdateUserNameUseCase implements UseCase<DataState<void>, String> {
  final UserRepository _repo;
  UpdateUserNameUseCase(this._repo);

  @override
  Future<DataState<void>> call({String? params}) {
    return _repo.updateUserName(params ?? '');
  }
}


