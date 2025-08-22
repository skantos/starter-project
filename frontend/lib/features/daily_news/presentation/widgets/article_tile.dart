import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/article.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;
  final bool isOwner;
  final VoidCallback? onOwnerEdit;
  final VoidCallback? onOwnerDelete;

  const ArticleWidget({
    Key? key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
    this.isOwner = false,
    this.onOwnerEdit,
    this.onOwnerDelete,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen superior
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: _buildImage(context, height: 180),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _buildTitleAndDescription(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildMetaRow(),
            ),
            if (isOwner)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF2A85FF)),
                      onPressed: onOwnerEdit,
                      tooltip: 'Editar',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: onOwnerDelete,
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, {double height = 160}) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFF3F5F7),
      child: article?.urlToImage != null && article!.urlToImage!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: article!.urlToImage!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CupertinoActivityIndicator(
                  color: Color(0xFF2A85FF),
                ),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFFCCCCCC),
                  size: 32,
                ),
              ),
            )
          : const Center(
              child: Icon(
                Icons.article_outlined,
                color: Color(0xFFCCCCCC),
                size: 32,
              ),
            ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Title + category
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article?.title ?? 'Sin título',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Butler',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Color(0xFF2D2D2D),
                  height: 1.3,
                ),
              ),
              if ((article?.category ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article!.category!,
                    style: const TextStyle(
                      color: Color(0xFF2A85FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Description
          if (article?.description != null && article!.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                article!.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6E7C87),
                  height: 1.4,
                ),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    final String fallbackAuthor = (article?.author?.isNotEmpty ?? false) ? article!.author! : 'Usuario';
    return Row(
      children: [
        const Icon(Icons.person_outline, size: 14, color: Color(0xFF6E7C87)),
        const SizedBox(width: 6),
        Expanded(child: _buildAuthorName(fallbackAuthor)),
        const SizedBox(width: 8),
        const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF6E7C87)),
        const SizedBox(width: 4),
        Text(
          _formatDate(article?.publishedAt),
          style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C87)),
        ),
        if (isRemovable == true) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Quitar de favoritos',
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: onRemove != null && article != null ? () => onRemove!(article!) : null,
          ),
        ],
      ],
    );
  }

  Widget _buildAuthorName(String fallbackAuthor) {
    final String? authorId = article?.authorId;
    final String authorField = (article?.author ?? '').trim();

    Future<String> _resolveName() async {
      // 1) Si hay authorId, usa el perfil del usuario
      if (authorId != null && authorId.isNotEmpty) {
        try {
          final snap = await FirebaseFirestore.instance.collection('users').doc(authorId).get();
          final String name = (snap.data()?['name'] ?? '').toString().trim();
          if (name.isNotEmpty) return name;
        } catch (_) {}
      }
      // 2) Si no hay authorId pero el campo author parece email, intenta buscar por email
      if (authorField.contains('@')) {
        try {
          final query = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: authorField)
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            final String name = (query.docs.first.data()['name'] ?? '').toString().trim();
            if (name.isNotEmpty) return name;
          }
        } catch (_) {}
      }
      // 3) Fallback al campo author (podría ser nombre ya) o etiqueta genérica
      return authorField.isNotEmpty ? authorField : fallbackAuthor;
    }

    return FutureBuilder<String>(
      future: _resolveName(),
      builder: (context, snapshot) {
        final String label = (snapshot.data ?? fallbackAuthor);
        return Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C87)),
        );
      },
    );
  }

  // Área de eliminación ya no se usa en el layout vertical. Se mantiene vacío para compatibilidad.

  void _onTap() {
    if (onArticlePressed != null) {
      onArticlePressed!(article!);
    }
  }
}