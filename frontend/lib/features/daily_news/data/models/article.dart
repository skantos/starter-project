import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';

class ArticleModel extends ArticleEntity {
  const ArticleModel({
    int ? id,
    String ? author,
    String ? authorId,
    String ? title,
    String ? description,
    String ? url,
    String ? urlToImage,
    String ? publishedAt,
    String ? content,
    String ? category,
  }): super(
    id: id,
    author: author,
    authorId: authorId,
    title: title,
    description: description,
    url: url,
    urlToImage: urlToImage,
    publishedAt: publishedAt,
    content: content,
    category: category,
  );

  factory ArticleModel.fromJson(Map < String, dynamic > map) {
    return ArticleModel(
      author: map['author'] ?? "",
      authorId: map['authorId'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      urlToImage: map['urlToImage'] != null && map['urlToImage'] != "" ? map['urlToImage'] : kDefaultImage,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
      category: map['category'] ?? "",
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      author: entity.author,
      authorId: entity.authorId,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
      category: entity.category,
    );
  }
}