import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';

class CommentService {
  final String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // GET comments for a post
  Future<List<Comment>> getComments(int categoryId, int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$categoryId/posts/$postId/comments'),
    );

    print("COMMENTS RESPONSE (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List jsonList = jsonData['data'];
      return jsonList.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  // CREATE a new comment (без Authorization)
  Future<bool> createComment(int categoryId, int postId, String body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories/$categoryId/posts/$postId/comments'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'body': body}),
    );

    print("CREATE COMMENT RESPONSE (${response.statusCode}): ${response.body}");

    return response.statusCode == 201;
  }
}
