import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';


class ArticleRepositoryImpl implements ArticleRepository {
  ArticleRepositoryImpl();
  
  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
   try {
    final query = await FirebaseFirestore.instance
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();

    final List<ArticleModel> list = await Future.wait(query.docs.map((doc) async {
      final data = doc.data();
      final thumbStored = (data['thumbnailURL'] ?? '') as String;
      String thumbUrl = '';
      if (thumbStored.isNotEmpty) {
        try {
          if (thumbStored.startsWith('http')) {
            thumbUrl = thumbStored;
          } else if (thumbStored.startsWith('gs://')) {
            thumbUrl = await FirebaseStorage.instance.refFromURL(thumbStored).getDownloadURL();
          } else {
            thumbUrl = await FirebaseStorage.instance.ref().child(thumbStored).getDownloadURL();
          }
        } catch (_) {
          thumbUrl = kDefaultImage;
        }
      }
      final content = (data['content'] ?? '') as String;
      final category = (data['category'] ?? '') as String;
      final title = (data['title'] ?? '') as String;
      final description = (data['description'] ?? content) as String;
      final author = (data['author'] ?? 'Anonymous') as String;
      final authorId = (data['authorId'] ?? '') as String;
      final ts = data['publishedAt'];
      String publishedAt = '';
      if (ts is Timestamp) {
        publishedAt = ts.toDate().toIso8601String();
      } else if (ts != null) {
        publishedAt = ts.toString();
      }
      return ArticleModel(
        author: author,
        authorId: authorId,
        title: title,
        description: description,
        url: doc.id,
        urlToImage: thumbUrl.isNotEmpty ? thumbUrl : kDefaultImage,
        publishedAt: publishedAt,
        content: content,
        category: category,
      );
    }).toList());

    return DataSuccess(list);
   } catch (e) {
    return DataFailed(
      DioException(requestOptions: RequestOptions(path: '/firestore'), error: e),
    );
   }
  }

  @override
  Future<DataState<List<ArticleModel>>> getSavedArticles() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return DataSuccess(const <ArticleModel>[]);
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('createdAt', descending: true)
          .get();

      final List<ArticleModel> list = await Future.wait(query.docs.map((doc) async {
        final data = doc.data();
        final thumbStored = (data['thumbnailURL'] ?? '') as String;
        String thumbUrl = '';
        if (thumbStored.isNotEmpty) {
          try {
            if (thumbStored.startsWith('http')) {
              thumbUrl = thumbStored;
            } else if (thumbStored.startsWith('gs://')) {
              thumbUrl = await FirebaseStorage.instance.refFromURL(thumbStored).getDownloadURL();
            } else {
              thumbUrl = await FirebaseStorage.instance.ref().child(thumbStored).getDownloadURL();
            }
          } catch (_) {
            thumbUrl = kDefaultImage;
          }
        }
        return ArticleModel(
          author: (data['author'] ?? '') as String,
          authorId: (data['authorId'] ?? '') as String,
          title: (data['title'] ?? '') as String,
          description: (data['description'] ?? data['content'] ?? '') as String,
          url: (data['url'] ?? doc.id) as String,
          urlToImage: thumbUrl.isNotEmpty ? thumbUrl : kDefaultImage,
          publishedAt: (data['publishedAt']?.toString() ?? ''),
          content: (data['content'] ?? '') as String,
          category: (data['category'] ?? '') as String,
        );
      }).toList());

      return DataSuccess(list);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: '/firestore/favorites'), error: e));
    }
  }

  @override
  Future<DataState<void>> removeArticle(ArticleEntity article) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return const DataSuccess(null);
      final String id = (article.url ?? article.title ?? DateTime.now().millisecondsSinceEpoch.toString());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(id)
          .delete();
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: '/firestore/favorites/remove'), error: e));
    }
  }

  @override
  Future<DataState<void>> saveArticle(ArticleEntity article) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return const DataSuccess(null);
      final String id = (article.url ?? article.title ?? DateTime.now().millisecondsSinceEpoch.toString());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(id)
          .set({
        'author': article.author ?? '',
        'authorId': article.authorId ?? '',
        'title': article.title ?? '',
        'description': article.description ?? '',
        'content': article.content ?? '',
        'category': article.category ?? '',
        'url': article.url ?? id,
        'urlToImage': article.urlToImage ?? kDefaultImage,
        'thumbnailURL': article.urlToImage ?? kDefaultImage,
        'publishedAt': article.publishedAt ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: '/firestore/favorites/save'), error: e));
    }
  }

  @override
  Future<DataState<bool>> isArticleSaved(String articleId) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null || articleId.isEmpty) return const DataSuccess(false);
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(articleId)
          .get();
      return DataSuccess(doc.exists);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: '/firestore/favorites/isSaved'), error: e));
    }
  }

  @override
  Future<DataState<int>> getFavoritesCount({String? userId}) async {
    try {
      final String? uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return const DataSuccess(0);
      final agg = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .count()
          .get();
      return DataSuccess(agg.count ?? 0);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: '/firestore/favorites/count'), error: e));
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getArticlesByAuthor(String authorId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('articles')
          .where('authorId', isEqualTo: authorId)
          .get();
      final List<ArticleEntity> list = await Future.wait(query.docs.map((doc) async {
        final data = doc.data();
        final String stored = (data['thumbnailURL'] ?? '') as String;
        String thumbUrl = '';
        if (stored.isNotEmpty) {
          try {
            if (stored.startsWith('http')) {
              thumbUrl = stored;
            } else if (stored.startsWith('gs://')) {
              thumbUrl = await FirebaseStorage.instance.refFromURL(stored).getDownloadURL();
            } else {
              thumbUrl = await FirebaseStorage.instance.ref().child(stored).getDownloadURL();
            }
          } catch (_) {
            thumbUrl = kDefaultImage;
          }
        }
        final ts = data['publishedAt'];
        String publishedAt = '';
        if (ts is Timestamp) {
          publishedAt = ts.toDate().toIso8601String();
        } else if (ts != null) {
          publishedAt = ts.toString();
        }
        return ArticleModel(
          author: (data['author'] ?? '') as String,
          authorId: (data['authorId'] ?? '') as String,
          title: (data['title'] ?? '') as String,
          description: (data['content'] ?? '') as String,
          url: doc.id,
          urlToImage: thumbUrl.isNotEmpty ? thumbUrl : kDefaultImage,
          publishedAt: publishedAt,
          content: (data['content'] ?? '') as String,
          category: (data['category'] ?? '') as String,
        );
      }).toList());
      return DataSuccess(list);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: '/firestore/articles/byAuthor'), error: e));
    }
  }

  Future<DataState<void>> deleteArticleById(String id) async {
    try {
      if (id.isEmpty) return const DataSuccess(null);
      await FirebaseFirestore.instance.collection('articles').doc(id).delete();
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: '/firestore/articles/delete'), error: e));
    }
  }
  
}