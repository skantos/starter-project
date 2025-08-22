import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final User? _user;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D2D2D),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildMetrics(context),
            const SizedBox(height: 20),
            const Text('Mis artículos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D))),
            const SizedBox(height: 8),
            _buildMyArticlesList(context),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final String email = _user?.email ?? 'Invitado';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
      ]),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2A85FF),
            child: Text(_initialsFromEmail(email), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: _user != null ? FirebaseFirestore.instance.collection('users').doc(_user!.uid).get() : null,
                builder: (context, snapshot) {
                  final String name = (snapshot.data?.data()?['name'] ?? '').toString();
                  return Text(name.isNotEmpty ? name : 'Usuario', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
                },
              ),
              Text(email, style: const TextStyle(color: Color(0xFF6E7C87))),
            ]),
          ),
          TextButton(
            onPressed: () async {
              if (_user == null) return;
              final controller = TextEditingController();
              final bool? ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Editar nombre'),
                  content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nombre')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
                  ],
                ),
              );
              if (ok == true && controller.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({'name': controller.text.trim()}, SetOptions(merge: true));
                if (mounted) setState(() {});
              }
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  // ===== Menú flotante tipo hamburguesa =====
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
                  if (mounted) setState(() {});
                }),
                _menuSquare(right: 8, bottom: 136, icon: Icons.person_outline, onTap: () async {
                  setState(() => _isMenuOpen = false);
                  if (mounted) setState(() {});
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
                  backgroundColor: const Color(0xFF2A85FF),
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

  Widget _labelPill(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A85FF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: const Color(0xFF2A85FF)),
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
            color: const Color(0xFF2A85FF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 6)),
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

  Widget _buildMetrics(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: _loadCounts(),
      builder: (context, snapshot) {
        final int articles = snapshot.data != null && snapshot.data!.isNotEmpty ? snapshot.data![0] : 0;
        final int favorites = snapshot.data != null && snapshot.data!.length > 1 ? snapshot.data![1] : 0;

        Widget metric(String title, String value, IconData icon, Color color) {
          return Expanded(
            child: Container(
              height: 72,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
              ]),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C87))),
                  ]),
                ),
              ]),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(children: [
            metric('Artículos', '$articles', Icons.article_outlined, const Color(0xFF2A85FF)),
            metric('Favoritos', '$favorites', Icons.bookmark_border, const Color(0xFFFFB020)),
          ]),
        );
      },
    );
  }

  Widget _buildMyArticlesList(BuildContext context) {
    if (_user == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('Inicia sesión para ver tus artículos'),
      );
    }
    final Stream<QuerySnapshot<Map<String, dynamic>>> stream = FirebaseFirestore.instance
        .collection('articles')
        .where('authorId', isEqualTo: _user!.uid)
        // evitamos índice compuesto requerido; si quieres ordenar, crear índice y reactivar orderBy
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('Aún no has publicado artículos'),
          );
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data();

            final String storedThumb = (data['thumbnailURL'] ?? '') as String;
            Future<String> resolveThumb() async {
              if (storedThumb.isEmpty) return kDefaultImage;
              try {
                if (storedThumb.startsWith('http')) return storedThumb;
                if (storedThumb.startsWith('gs://')) {
                  return await FirebaseStorage.instance.refFromURL(storedThumb).getDownloadURL();
                }
                return await FirebaseStorage.instance.ref().child(storedThumb).getDownloadURL();
              } catch (_) {
                return kDefaultImage;
              }
            }

            final dynamic ts = data['publishedAt'];
            String publishedAt = '';
            if (ts is Timestamp) {
              publishedAt = ts.toDate().toIso8601String();
            } else if (ts != null) {
              publishedAt = ts.toString();
            }

            return FutureBuilder<String>(
              future: resolveThumb(),
              builder: (context, snapImg) {
                final article = ArticleEntity(
                  author: (data['author'] ?? '') as String,
                  authorId: (data['authorId'] ?? '') as String,
                  title: (data['title'] ?? '') as String,
                  description: (data['content'] ?? '') as String,
                  url: doc.id,
                  urlToImage: (snapImg.data ?? kDefaultImage),
                  publishedAt: publishedAt,
                  content: (data['content'] ?? '') as String,
                  category: (data['category'] ?? '') as String,
                );
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ArticleWidget(
                    article: article,
                    isOwner: true,
                    onOwnerEdit: () => _onEditArticle(context, article),
                    onOwnerDelete: () => _onDeleteArticle(context, article),
                    onArticlePressed: (a) {},
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<int>> _loadCounts() async {
    if (_user == null) return [0, 0];
    try {
      final agg1 = await FirebaseFirestore.instance.collection('articles').where('authorId', isEqualTo: _user!.uid).count().get();
      final agg2 = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('favorites').count().get();
      return [agg1.count ?? 0, agg2.count ?? 0];
    } catch (_) {
      return [0, 0];
    }
  }

  String _initialsFromEmail(String email) {
    final name = email.split('@').first;
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
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
      Navigator.pushNamed(context, '/createArticle', arguments: article);
    }
  }

  Future<void> _onDeleteArticle(BuildContext context, ArticleEntity article) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: const Text('¿Estás seguro de eliminar este artículo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final String? id = article.url;
        if (id != null && id.isNotEmpty) {
          await FirebaseFirestore.instance.collection('articles').doc(id).delete();
          if (mounted) setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      }
    }
  }
}


