import 'package:flutter/foundation.dart';

@immutable
class FeedItem {
  const FeedItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.imageUrl,
    required this.publishedAt,
    this.likeCount = 0,
    this.isLiked = false,
  });

  final String id;
  final String title;
  final String summary;
  final String category;
  final String imageUrl;
  final DateTime publishedAt;
  final int likeCount;
  final bool isLiked;

  FeedItem copyWith({
    String? id,
    String? title,
    String? summary,
    String? category,
    String? imageUrl,
    DateTime? publishedAt,
    int? likeCount,
    bool? isLiked,
  }) {
    return FeedItem(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      imageUrl: json['imageUrl'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'category': category,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'likeCount': likeCount,
      'isLiked': isLiked,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          likeCount == other.likeCount &&
          isLiked == other.isLiked;

  @override
  int get hashCode => id.hashCode ^ likeCount.hashCode ^ isLiked.hashCode;
}
