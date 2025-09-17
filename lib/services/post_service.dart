import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/category.dart';

class PostService {
  final String baseUrl = 'http://10.0.2.2:8000/api/v1';

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  List<dynamic> _extractDataFromResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        return responseData['data'];
      } else {
        throw Exception('Unexpected API response format: $responseData');
      }
    } else if (responseData is List<dynamic>) {
      return responseData;
    } else {
      throw Exception('Unexpected API response type: ${responseData.runtimeType}');
    }
  }

  Future<List<Post>> getPosts({int? categoryId}) async {
    try {
      Map<String, String> queryParams = {};
      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/posts').replace(queryParameters: queryParams),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final List<dynamic> postsList = _extractDataFromResponse(data);
        return postsList.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final List<dynamic> categoriesList = _extractDataFromResponse(data);
        return categoriesList.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<bool> createPost({
    required String title,
    required String slug,
    required String body,
    required int userId,
    required int categoryId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'title': title,
        'slug': slug,
        'body': body,
        'user_id': userId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/categories/$categoryId/posts'),
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }

  Future<List<Post>> getUserPosts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts?user_id=$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final List<dynamic> postsList = _extractDataFromResponse(data);
        return postsList.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user posts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching user posts: $e');
      throw Exception('Failed to load user posts');
    }
  }
}