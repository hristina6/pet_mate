class Comment {
  final int id;
  final String body;
  final int userId;
  final String userName;
  final int postId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.body,
    required this.userId,
    required this.userName,
    required this.postId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      userId: json['user_id'] ?? 0,
      userName: _extractUserName(json),
      postId: json['post_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
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

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'user_id': userId,
      'post_id': postId,
    };
  }
}