import 'package:news_app_clean_architecture/core/resources/data_state.dart';

abstract class UserRepository {
  Future<DataState<void>> updateUserName(String name);
  Future<DataState<String>> getUserName(String userId);
  Future<DataState<String?>> getCurrentUserId();
}


