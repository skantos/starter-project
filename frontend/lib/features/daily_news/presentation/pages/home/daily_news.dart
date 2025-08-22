import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';

const Color _primaryBlue = Color(0xFF2A85FF);

class DailyNews extends StatefulWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  String _selectedCategory = 'Todas';
  int _favoritesCount = 0;
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  _buildSliverAppBar(BuildContext context) {
    return const SliverAppBar(
      pinned: true,
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 1,
      title: Text(
        'Noticias Diarias',
        style: TextStyle(
          color: Color(0xFF2D2D2D),
          fontSize: 24,
          fontWeight: FontWeight.w800,
          fontFamily: 'Butler',
        ),
      ),
    );
  }

  _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return _buildHomeScaffold(
            context,
            const <ArticleEntity>[],
            const SliverToBoxAdapter(
              child: EmptyView(
                title: 'Sin artículos por ahora',
                actionLabel: 'Publicar artículo',
              ),
            ),
          );
        }
        if (state is RemoteArticlesError) {
          return _buildHomeScaffold(
            context,
            const <ArticleEntity>[],
            SliverToBoxAdapter(
              child: ErrorView(
                onRetry: () => context.read<RemoteArticlesBloc>().add(const GetArticles()),
              ),
            ),
          );
        }
        if (state is RemoteArticlesDone) {
          List<ArticleEntity> list = state.articles ?? [];
          if (_selectedCategory != 'Todas') {
            list = list.where((a) => (a.category ?? '').toLowerCase() == _selectedCategory.toLowerCase()).toList();
          }
          if (list.isEmpty) {
            return _buildHomeScaffold(
              context,
              list,
              SliverToBoxAdapter(
                child: EmptyView(
                  title: 'Aún no hay artículos',
                  actionLabel: 'Publicar artículo',
                  onAction: () => _onFabPressed(context),
                ),
              ),
            );
          }
          return _buildArticlesPage(context, list);
        }
        return _buildHomeScaffold(
          context,
          const <ArticleEntity>[],
          SliverToBoxAdapter(
            child: EmptyView(
              title: 'Aún no hay artículos',
              actionLabel: 'Publicar artículo',
              onAction: () => _onFabPressed(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticlesPage(BuildContext context, List<ArticleEntity> articles) {
    return _buildHomeScaffold(
      context,
      articles,
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final article = articles[index];
              final User? current = FirebaseAuth.instance.currentUser;
              final String? author = article.author;
              final String? authorId = article.authorId;
              final bool owner = current != null && (
                (authorId != null && authorId.isNotEmpty && authorId == current.uid) ||
                (author != null && author.isNotEmpty && author.toLowerCase() == (current.email ?? '').toLowerCase())
              );
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: ArticleWidget(
                  article: article,
                  onArticlePressed: (article) => _onArticlePressed(context, article),
                  isOwner: owner,
                  onOwnerEdit: () => _onEditArticle(context, article),
                  onOwnerDelete: () => _onDeleteArticle(context, article),
                ),
              );
            },
            childCount: articles.length,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScaffold(BuildContext context, List<ArticleEntity> articles, Widget sliverBody) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async {
          if (mounted) {
            context.read<RemoteArticlesBloc>().add(const GetArticles());
            await _loadMetrics();
          }
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildTopMetrics(context, articles),
                  const SizedBox(height: 12),
                  _buildCategoryChips(context, articles),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            sliverBody,
          ],
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildTopMetrics(BuildContext context, List<ArticleEntity> articles) {
    final int totalArticulos = articles.length;
    final int favoritos = _favoritesCount;

    Widget _metric(String title, String value, IconData icon, Color color) {
      return Expanded(
        child: Container(
          height: 72,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C87))),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _metric('Artículos', '$totalArticulos', Icons.article_outlined, const Color(0xFF2A85FF)),
          _metric('Favoritos', '$favoritos', Icons.bookmark_border, const Color(0xFFFFB020)),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, List<ArticleEntity> articles) {
    final List<String> categories = ['Todas', ...{
      for (final a in articles) (a.category ?? '').trim()
    }..removeWhere((e) => e.isEmpty)].toList();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final String cat = categories[index];
          final bool selected = cat == _selectedCategory;
          return ChoiceChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) => setState(() => _selectedCategory = cat),
            selectedColor: const Color(0xFF2A85FF),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF2D2D2D),
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: categories.length,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    // Contar favoritos del usuario autenticado en Firestore
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _favoritesCount = 0);
        return;
      }
      final agg = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .count()
          .get();
      setState(() => _favoritesCount = agg.count ?? 0);
    } catch (_) {
      setState(() => _favoritesCount = 0);
    }
  }

  Future<void> _onArticlePressed(BuildContext context, ArticleEntity article) async {
    await Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
    if (mounted) {
      _loadMetrics();
    }
  }

  Future<void> _onEditArticle(BuildContext context, ArticleEntity article) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar artículo'),
        content: const Text('¿Deseas editar este artículo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continuar')),
        ],
      ),
    );
    if (confirmed == true) {
      // Redirige a publicar con el artículo como argumento para precargar
      Navigator.pushNamed(context, '/createArticle', arguments: article);
    }
  }

  Future<void> _onDeleteArticle(BuildContext context, ArticleEntity article) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: const Text('¿Estás seguro de eliminar este artículo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final String? id = article.url; // usamos url como id del doc
        if (id != null && id.isNotEmpty) {
          await FirebaseFirestore.instance.collection('articles').doc(id).delete();
          if (mounted) {
            context.read<RemoteArticlesBloc>().add(const GetArticles());
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      }
    }
  }

  Widget _buildFab(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final bool isLoggedIn = snapshot.data != null;
        return SizedBox(
          width: 260,
          height: 320,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                right: _isMenuOpen ? 72 : 8,
                bottom: 8,
                child: AnimatedOpacity(
                  opacity: _isMenuOpen ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: _labelPill(
                    isLoggedIn ? 'Cerrar sesión' : 'Iniciar sesión',
                    onTap: () async {
                      if (isLoggedIn) {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) setState(() => _isMenuOpen = false);
                      } else {
                        if (mounted) setState(() => _isMenuOpen = false);
                        if (context.mounted) {
                          Navigator.pushNamed(context, '/login');
                        }
                      }
                    },
                  ),
                ),
              ),

              if (_isMenuOpen && isLoggedIn) ...[
                _menuSquare(right: 8, bottom: 76, icon: Icons.bookmark_border, onTap: () async {
                  setState(() => _isMenuOpen = false);
                  await Navigator.pushNamed(context, '/SavedArticles');
                  if (mounted) _loadMetrics();
                }),
                _menuSquare(right: 8, bottom: 136, icon: Icons.person_outline, onTap: () async {
                  setState(() => _isMenuOpen = false);
                  await Navigator.pushNamed(context, '/profile');
                  if (mounted) _loadMetrics();
                }),
                _menuSquare(right: 8, bottom: 196, icon: Icons.add, onTap: () {
                  setState(() => _isMenuOpen = false);
                  _onFabPressed(context);
                }),
              ],

              Positioned(
                right: 8,
                bottom: 8,
                child: FloatingActionButton(
                  onPressed: () => setState(() => _isMenuOpen = !_isMenuOpen),
                  backgroundColor: _primaryBlue,
                  child: Icon(
                    _isMenuOpen ? Icons.close : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // _miniFab ya no se usa; reemplazado por _menuSquare

  Widget _labelPill(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _primaryBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: _primaryBlue),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuSquare({required double right, required double bottom, required IconData icon, required VoidCallback onTap}) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      right: right,
      bottom: bottom,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _primaryBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 6)),
            ],
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  void _onFabPressed(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
    } else {
      Navigator.pushNamed(context, '/createArticle');
    }
  }

  // Banner de auth eliminado del AppBar
}