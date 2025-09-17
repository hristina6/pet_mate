import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../services/comment_service.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../models/comment.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final PostService _postService = PostService();
  final CommentService _commentService = CommentService();
  late Future<List<Post>> _postsFuture;
  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _postsFuture = _loadPosts();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _postService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  Future<List<Post>> _loadPosts() async {
    try {
      return await _postService.getPosts(categoryId: _selectedCategoryId);
    } catch (e) {
      print('Error loading posts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load posts: $e')),
      );
      return [];
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final posts = await _loadPosts();
      setState(() {
        _postsFuture = Future.value(posts);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔽 Дијалог за додавање коментар
  void _showAddCommentDialog(BuildContext context, Post post) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            hintText: "Write your comment...",
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Comment cannot be empty")),
                );
                return;
              }

              try {
                final success = await _commentService.createComment(
                  post.categoryId,
                  post.id,
                  commentController.text.trim(),
                );

                Navigator.pop(context);

                if (success) {
                  setState(() {}); // рефреш за да се вчитаат новите коментари
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Comment added")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ Failed to add comment")),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Failed to add comment: $e")),
                );
              }
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  // 🔽 Картичка со пост + коментари
  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          post.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          post.body.length > 100 ? '${post.body.substring(0, 100)}...' : post.body,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("By: ${post.userName} • ${post.categoryName}"),
                Text("Slug: ${post.slug}"),
              ],
            ),
          ),

          // 🔽 Коментари
          FutureBuilder<List<Comment>>(
            future: _commentService.getComments(post.categoryId, post.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("⚠️ Error loading comments: ${snapshot.error}"),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("No comments yet"),
                );
              } else {
                return Column(
                  children: snapshot.data!
                      .map((comment) => ListTile(
                    leading: const Icon(Icons.comment),
                    title: Text(comment.body),
                    subtitle: Text("By: ${comment.userName}"),
                  ))
                      .toList(),
                );
              }
            },
          ),

          // ➕ Копче за додавање коментар
          TextButton.icon(
            onPressed: () => _showAddCommentDialog(context, post),
            icon: const Icon(Icons.add_comment),
            label: const Text("Add Comment"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPosts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ..._categories.map((Category category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
              ],
              onChanged: (int? value) {
                setState(() {
                  _selectedCategoryId = value;
                });
                _refreshPosts();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No posts found"),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: _refreshPosts,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data![index];
                        return _buildPostCard(post);
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
