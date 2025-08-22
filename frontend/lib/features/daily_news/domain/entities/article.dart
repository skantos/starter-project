import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable{
  final int ? id;
  final String ? author;
  final String ? authorId;
  final String ? title;
  final String ? description;
  final String ? url;
  final String ? urlToImage;
  final String ? publishedAt;
  final String ? content;
  final String ? category;

  const ArticleEntity({
    this.id,
    this.author,
    this.authorId,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.category,
  });

  @override
  List < Object ? > get props {
    return [
      id,
      author,
      authorId,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
      category,
    ];
  }
}