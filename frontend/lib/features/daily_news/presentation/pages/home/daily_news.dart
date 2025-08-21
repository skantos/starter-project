import 'package:flutter/cupertino.dart';
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
      centerTitle: true,
      title: const Text('Daily News', style: TextStyle(color: Colors.black)),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.bookmark_border, color: Colors.black),
          ),
        ),
      ],
    );
  }

  _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(body: const LoadingShimmer());
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
            body: ErrorView(
              onRetry: () => context.read<RemoteArticlesBloc>().add(GetArticles()),
            ),
          );
        }
        if (state is RemoteArticlesDone) {
          final list = state.articles ?? [];
          if (list.isEmpty) {
            return Scaffold(
              body: EmptyView(
                title: 'Aún no hay artículos',
                actionLabel: 'Publicar artículo',
                onAction: () => Navigator.pushNamed(context, '/createArticle'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/createArticle'),
                child: const Icon(Icons.add),
              ),
            );
          }
          return _buildArticlesPage(context, list);
        }
        return Scaffold(
          body: EmptyView(
            title: 'Aún no hay artículos',
            actionLabel: 'Publicar artículo',
            onAction: () => Navigator.pushNamed(context, '/createArticle'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/createArticle'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    List<Widget> articleWidgets = [];
    for (var article in articles) {
      articleWidgets.add(ArticleWidget(
        article: article,
        onArticlePressed: (article) => _onArticlePressed(context, article),
      ));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate(articleWidgets),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createArticle');
        },
        child: const Icon(Icons.add),
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
