import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_favorites_count.dart';

abstract class FavoritesCountState {
  const FavoritesCountState();
}

class FavoritesCountLoading extends FavoritesCountState {
  const FavoritesCountLoading();
}

class FavoritesCountLoaded extends FavoritesCountState {
  final int count;
  const FavoritesCountLoaded(this.count);
}

class FavoritesCountError extends FavoritesCountState {
  final String message;
  const FavoritesCountError(this.message);
}

class FavoritesCountCubit extends Cubit<FavoritesCountState> {
  final GetFavoritesCountUseCase _useCase;
  FavoritesCountCubit(this._useCase) : super(const FavoritesCountLoading());

  Future<void> load({String? userId}) async {
    emit(const FavoritesCountLoading());
    final res = await _useCase(params: userId);
    if (res is DataSuccess<int>) {
      emit(FavoritesCountLoaded(res.data ?? 0));
    } else {
      emit(FavoritesCountError(res.error?.message ?? 'Error'));
    }
  }
}


