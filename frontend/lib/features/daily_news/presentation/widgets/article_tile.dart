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

  const ArticleWidget({
    Key? key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.width / 2.2,
        child: Row(
          children: [
            _buildImage(context),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTitleAndDescription(),
            ),
            _buildRemovableArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        height: double.maxFinite,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F7),
          borderRadius: BorderRadius.circular(12),
        ),
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
      ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            article?.title ?? 'Sin título',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Butler',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF2D2D2D),
              height: 1.3,
            ),
          ),

          // Description
          if (article?.description != null && article!.description!.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  article!.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E7C87),
                    height: 1.4,
                  ),
                ),
              ),
            ),

          // Datetime
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.access_time,
                  size: 12,
                  color: Color(0xFF6E7C87),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(article?.publishedAt),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6E7C87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableArea() {
    if (isRemovable!) {
      return GestureDetector(
        onTap: _onRemove,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.remove_circle_outline,
            color: Colors.red,
            size: 20,
          ),
        ),
      );
    }
    return Container();
  }

  void _onTap() {
    if (onArticlePressed != null) {
      onArticlePressed!(article!);
    }
  }

  void _onRemove() {
    if (onRemove != null) {
      onRemove!(article!);
    }
  }
}