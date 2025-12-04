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
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];

  List<Category> _categories = [];
  int? _selectedCategoryId;

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  // Sorting variables
  String _sortOrder = 'newest'; // 'newest' or 'oldest'

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _postsFuture = _loadPosts();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _postService.getCategories();
      setState(() => _categories = categories);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load categories: $e")));
    }
  }

  Future<List<Post>> _loadPosts() async {
    try {
      final posts =
      await _postService.getPosts(categoryId: _selectedCategoryId);

      _allPosts = posts;
      _filteredPosts = _applySorting(posts);

      return _filteredPosts;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load posts: $e")));
      return [];
    }
  }

  List<Post> _applySorting(List<Post> posts) {
    List<Post> sortedPosts = List.from(posts);

    if (_sortOrder == 'newest') {
      sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      sortedPosts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return sortedPosts;
  }

  void _filterPosts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPosts = _applySorting(_allPosts);
      } else {
        _filteredPosts = _applySorting(_allPosts
            .where((post) =>
        post.title.toLowerCase().contains(query.toLowerCase()) ||
            post.body.toLowerCase().contains(query.toLowerCase()))
            .toList());
      }
    });
  }

  void _changeSortOrder(String? newOrder) {
    if (newOrder != null) {
      setState(() {
        _sortOrder = newOrder;
        _filteredPosts = _applySorting(_filteredPosts);
      });
    }
  }

  Future<void> _refreshPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _loadPosts();
      setState(() {
        _postsFuture = Future.value(posts);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Date formatting helper methods
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${_getMonthAbbreviation(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // ---------------------------------------
  // CATEGORY CIRCLES
  // ---------------------------------------
  Widget _buildCategoryCircles() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryCircle(
            id: null,
            label: "All",
            icon: Icons.filter_list,
          ),
          ..._categories.map(
                (cat) => _buildCategoryCircle(
              id: cat.id,
              label: cat.name,
              icon: Icons.category,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCircle({
    required int? id,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedCategoryId == id;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategoryId = id);
        _refreshPosts();
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16, top: 8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: isSelected ? Colors.orange : Colors.grey[300],
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black54,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // POST CARD - UPDATED WITH TIMESTAMP AND CATEGORY BADGE
  // ----------------------------------------------------------
  Widget _buildPostCard(Post post) {
    String formattedDate = _formatDate(post.createdAt);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER - Updated layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey[400],
                  child: Text(
                    post.userName.isNotEmpty
                        ? post.userName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Category badge at top right
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    post.categoryName,
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              post.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              post.body.length > 180
                  ? "${post.body.substring(0, 180)}..."
                  : post.body,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 12),

            // COMMENTS SECTION
            FutureBuilder<List<Comment>>(
              future: _commentService.getComments(post.categoryId, post.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "No comments",
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                final comments = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Comments:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...comments.take(3).map((c) => _buildCommentPreview(c)),
                    if (comments.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          onTap: () => _showAllCommentsSheet(post, comments),
                          child: Text(
                            "View all ${comments.length} comments",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 10),

            // ADD COMMENT BUTTON
            GestureDetector(
              onTap: () => _showAddCommentSheet(post),
              child: Row(
                children: const [
                  Icon(Icons.mode_comment_outlined, color: Colors.orange),
                  SizedBox(width: 6),
                  Text("Add Comment", style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentPreview(Comment c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey[200],
            child: Text(
              c.userName.isNotEmpty ? c.userName[0].toUpperCase() : "?",
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  c.body,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // COMMENT SHEETS
  // ----------------------------------------------------------
  void _showAllCommentsSheet(Post post, List<Comment> comments) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Center(
                child: Text(
                  "Comments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    if (comments.isEmpty)
                      const Center(
                        child: Text(
                          "No comments yet",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ...comments.map((c) => _buildCommentBubble(c)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildAddCommentInput(post),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentBubble(Comment c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            child: Text(
              c.userName.isNotEmpty ? c.userName[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(c.body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCommentInput(Post post) {
    final controller = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Write a comment...",
              filled: true,
              fillColor: Colors.orange.withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          backgroundColor: Colors.orange,
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              await _commentService.createComment(
                post.categoryId,
                post.id,
                controller.text.trim(),
              );

              controller.clear();
              setState(() {});
            },
          ),
        )
      ],
    );
  }

  void _showAddCommentSheet(Post post) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: _buildAddCommentInput(post),
      ),
    );
  }

  // ----------------------------------------------------------
  // UPDATED FILTER BUTTON WIDGET - SMALLER WITH SILVER/BLACK ARROWS
  // ----------------------------------------------------------
  Widget _buildFilterButton() {
    return Container(
      height: 40, // Smaller height
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Smaller radius
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortOrder,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
          elevation: 2,
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          borderRadius: BorderRadius.circular(10),
          onChanged: _changeSortOrder,
          items: const [
            DropdownMenuItem(
              value: 'newest',
              child: Row(
                children: [
                  Icon(Icons.arrow_downward, size: 14, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('Newest', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'oldest',
              child: Row(
                children: [
                  Icon(Icons.arrow_upward, size: 14, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('Oldest', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // MAIN BUILD - UPDATED WITH SMALLER FILTER BUTTON
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.orange));
            }

            return RefreshIndicator(
              color: Colors.orange,
              onRefresh: _refreshPosts,
              child: CustomScrollView(
                slivers: [
                  // TITLE SECTION - Fixed at the top
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              const Text(
                                "Posts",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              // Smaller filter button
                              _buildFilterButton(),
                              const SizedBox(width: 12),
                              // Notification bell
                              GestureDetector(
                                onTap: () {
                                  // Navigate to notifications if needed
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 40, // Smaller notification bell
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey[300]!, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.notifications_none,
                                        color: Colors.grey[700],
                                        size: 20, // Smaller icon
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '3',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SEARCH AND CATEGORIES - Scroll with content
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // SEARCH BAR
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Icon(Icons.search, color: Colors.grey[600], size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _filterPosts,
                                    decoration: const InputDecoration(
                                      hintText: 'Search posts...',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterPosts('');
                                    },
                                  ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),

                        // CATEGORIES
                        _buildCategoryCircles(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // POSTS LIST
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return _buildPostCard(_filteredPosts[index]);
                      },
                      childCount: _filteredPosts.length,
                    ),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}