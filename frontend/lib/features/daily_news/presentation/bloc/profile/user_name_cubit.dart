import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_user_name.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_user_name.dart';

class UserNameState {
  final String name;
  final bool loading;
  const UserNameState({required this.name, required this.loading});
  UserNameState copyWith({String? name, bool? loading}) => UserNameState(name: name ?? this.name, loading: loading ?? this.loading);
}

class UserNameCubit extends Cubit<UserNameState> {
  final UpdateUserNameUseCase _update;
  final GetUserNameUseCase _get;
  UserNameCubit(this._update, this._get) : super(const UserNameState(name: '', loading: false));

  Future<void> load(String uid) async {
    emit(state.copyWith(loading: true));
    final res = await _get(params: uid);
    if (res is DataSuccess<String>) {
      emit(UserNameState(name: res.data ?? '', loading: false));
    } else {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> update(String name, String uid) async {
    emit(state.copyWith(loading: true));
    await _update(params: name);
    await load(uid);
  }
}


