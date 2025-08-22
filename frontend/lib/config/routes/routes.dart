import 'package:flutter/material.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/publish/publish_article_page.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/daily_news/presentation/pages/login/login_page.dart';
import '../../features/daily_news/presentation/pages/login/register_page.dart';
import '../../features/daily_news/presentation/pages/profile/profile_page.dart';


class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews(), settings);

      case '/ArticleDetails':
        return _materialRoute(ArticleDetailsView(article: settings.arguments as ArticleEntity), settings);

      case '/SavedArticles':
        return _materialRoute(const SavedArticles(), settings);
      case '/login':
        return _materialRoute(const LoginPage(), settings);
      case '/register':
        return _materialRoute(const RegisterPage(), settings);
      case '/createArticle':
        return _materialRoute(const PublishArticlePage(), settings);
      case '/profile':
        return _materialRoute(const ProfilePage(), settings);
        
      default:
        return _materialRoute(const DailyNews(), settings);
    }
  }

  static Route<dynamic> _materialRoute(Widget view, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => view, settings: settings);
  }
}
