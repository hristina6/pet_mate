import 'comment.dart';

class Post {
  final int id;
  final String title;
  final String slug;
  final String body;
  final int userId;
  final String userName;
  final int categoryId;
  final String categoryName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  List<Comment> comments;

  Post({
    required this.id,
    required this.title,
    required this.slug,
    required this.body,
    required this.userId,
    required this.userName,
    required this.categoryId,
    required this.categoryName,
    required this.createdAt,
    this.updatedAt,
    this.comments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      body: json['body'] ?? '',
      userId: json['user_id'] ?? 0,
      userName: _extractUserName(json),
      categoryId: json['category_id'] ?? 0,
      categoryName: _extractCategoryName(json),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      comments: [],
    );
  }

  static String _extractUserName(Map<String, dynamic> json) {
    if (json['user'] is Map<String, dynamic>) {
      final userMap = json['user'] as Map<String, dynamic>;
      if (userMap['name'] != null) {
        return userMap['name'] as String;
      }
    }

    if (json['user_name'] != null) {
      return json['user_name'] as String;
    }

    if (json['user_id'] != null) {
      return 'User ${json['user_id']}';
    }

    return 'Unknown User';
  }

  static String _extractCategoryName(Map<String, dynamic> json) {
    if (json['category'] is Map<String, dynamic>) {
      final categoryMap = json['category'] as Map<String, dynamic>;
      if (categoryMap['name'] != null) {
        return categoryMap['name'] as String;
      }
    }

    if (json['category_name'] != null) {
      return json['category_name'] as String;
    }

    if (json['category_id'] != null) {
      return 'Category ${json['category_id']}';
    }

    return 'Unknown Category';
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'slug': slug,
      'body': body,
      'user_id': userId,
      'category_id': categoryId,
    };
  }
}