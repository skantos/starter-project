import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        'Noticias Diarias',
        style: TextStyle(
          color: Color(0xFF2D2D2D),
          fontSize: 24,
          fontWeight: FontWeight.w800,
          fontFamily: 'Butler',
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_border, 
                color: Color(0xFF2A85FF), size: 22),
          ),
        ),
      ],
    );
  }

  _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: const LoadingShimmer(),
          );
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: ErrorView(
              onRetry: () => context.read<RemoteArticlesBloc>().add(const GetArticles()),
            ),
          );
        }
        if (state is RemoteArticlesDone) {
          final list = state.articles ?? [];
          if (list.isEmpty) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              body: EmptyView(
                title: 'Aún no hay artículos',
                actionLabel: 'Publicar artículo',
                onAction: () => Navigator.pushNamed(context, '/createArticle'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/createArticle'),
                backgroundColor: const Color(0xFF2A85FF),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            );
          }
          return _buildArticlesPage(context, list);
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: EmptyView(
            title: 'Aún no hay artículos',
            actionLabel: 'Publicar artículo',
            onAction: () => Navigator.pushNamed(context, '/createArticle'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/createArticle'),
            backgroundColor: const Color(0xFF2A85FF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildArticlesPage(BuildContext context, List<ArticleEntity> articles) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final article = articles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ArticleWidget(
                      article: article,
                      onArticlePressed: (article) => _onArticlePressed(context, article),
                    ),
                  );
                },
                childCount: articles.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createArticle'),
        backgroundColor: const Color(0xFF2A85FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }
}