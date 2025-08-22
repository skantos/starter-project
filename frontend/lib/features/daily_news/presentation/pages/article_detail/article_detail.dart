import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  String _formatDate(dynamic date) {
    try {
      DateTime dateTime;
      
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is Timestamp) {
        dateTime = date.toDate();
      } else {
        return 'Fecha inválida';
      }
      
      return DateFormat('dd MMM yyyy • HH:mm').format(dateTime);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  String _getArticleContent() {
    // Prioriza el contenido sobre la descripción para evitar duplicados
    if (article?.content != null && article!.content!.isNotEmpty) {
      return article!.content!;
    }
    return article?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Ionicons.chevron_back, color: Colors.black, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleTitleAndDate(),
          _buildArticleImage(),
          _buildArticleContent(),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article!.title!,
            style: const TextStyle(
              fontFamily: 'Butler',
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.3,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 16),
          // DateTime
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Ionicons.time_outline, size: 16, color: Color(0xFF6E7C87)),
                const SizedBox(width: 6),
                Text(
                  _formatDate(article!.publishedAt), // Formatear fecha aquí
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E7C87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    return Container(
      width: double.maxFinite,
      height: 220,
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          article!.urlToImage!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: const Color(0xFFF3F5F7),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFF6E7C87),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF3F5F7),
              child: const Center(
                child: Icon(Ionicons.image_outline, color: Color(0xFFCCCCCC), size: 40),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildArticleContent() {
    final content = _getArticleContent();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.isNotEmpty)
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF444444),
              ),
            ),
          const SizedBox(height: 30),
          // Información adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Ionicons.information_outline, size: 18, color: Color(0xFF2A85FF)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Artículo de noticias',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D2D2D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final bool loggedIn = snapshot.data != null;
        if (!loggedIn) {
          return FloatingActionButton(
            onPressed: () => _onFloatingActionButtonPressed(context, false),
            backgroundColor: const Color(0xFF2A85FF),
            child: const Icon(Ionicons.bookmark_outline, color: Colors.white, size: 22),
          );
        }
        final String id = article!.url ?? article!.title ?? '';
        final User user = FirebaseAuth.instance.currentUser!;
        final docStream = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(id)
            .snapshots();
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docStream,
          builder: (context, favSnap) {
            final bool isFav = favSnap.data?.exists == true;
            return FloatingActionButton(
              onPressed: () => _onFloatingActionButtonPressed(context, true),
              backgroundColor: const Color(0xFF2A85FF),
              child: Icon(isFav ? Ionicons.bookmark : Ionicons.bookmark_outline, color: Colors.white, size: 22),
            );
          },
        );
      },
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _onFloatingActionButtonPressed(BuildContext context, bool loggedIn) async {
    if (!loggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    // Toggle: si existe en favoritos, eliminar; si no, guardar
    try {
      final String id = article!.url ?? article!.title ?? '';
      if (id.isEmpty) return;
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites').doc(id);
      final snap = await ref.get();
      if (snap.exists) {
        BlocProvider.of<LocalArticleBloc>(context).add(RemoveArticle(article!));
        _showSnack(context, 'Artículo quitado de favoritos');
      } else {
        BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
        _showSnack(context, 'Artículo guardado en favoritos');
      }
    } catch (e) {
      _showSnack(context, 'Error al actualizar favoritos: $e');
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2A85FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}