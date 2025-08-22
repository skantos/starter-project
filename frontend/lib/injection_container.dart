import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/daily_news/domain/usecases/get_favorites_count.dart';
import 'features/daily_news/domain/usecases/is_article_saved.dart';
import 'features/daily_news/domain/usecases/get_articles_by_author.dart';
import 'features/daily_news/domain/usecases/delete_article_by_id.dart';
import 'features/daily_news/domain/repository/user_repository.dart';
import 'features/daily_news/data/repository/user_repository_impl.dart';
import 'features/daily_news/domain/usecases/update_user_name.dart';
import 'features/daily_news/domain/usecases/get_user_name.dart';
import 'features/daily_news/domain/usecases/get_current_user_id.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  
  // Dio
  sl.registerSingleton<Dio>(Dio());

  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl());
  sl.registerSingleton<UserRepository>(UserRepositoryImpl());
  
  //UseCases
  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl())
  );

  sl.registerSingleton<GetSavedArticleUseCase>(
    GetSavedArticleUseCase(sl())
  );

  sl.registerSingleton<SaveArticleUseCase>(
    SaveArticleUseCase(sl())
  );
  
  sl.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(sl())
  );

  sl.registerSingleton<GetFavoritesCountUseCase>(GetFavoritesCountUseCase(sl()));
  sl.registerSingleton<IsArticleSavedUseCase>(IsArticleSavedUseCase(sl()));
  sl.registerSingleton<GetArticlesByAuthorUseCase>(GetArticlesByAuthorUseCase(sl()));
  sl.registerSingleton<DeleteArticleByIdUseCase>(DeleteArticleByIdUseCase(sl()));
  sl.registerSingleton<UpdateUserNameUseCase>(UpdateUserNameUseCase(sl()));
  sl.registerSingleton<GetUserNameUseCase>(GetUserNameUseCase(sl()));
  sl.registerSingleton<GetCurrentUserIdUseCase>(GetCurrentUserIdUseCase(sl()));


  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl())
  );

  sl.registerFactory<LocalArticleBloc>(() => LocalArticleBloc(sl(), sl(), sl()));


}