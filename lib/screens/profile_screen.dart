// screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/post.dart';
import '../services/pet_service.dart';
import '../services/post_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final int userId;

  const ProfileScreen({super.key, required this.userName, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PetService _petService = PetService();
  final PostService _postService = PostService();

  late Future<List<Pet>> _userPetsFuture;
  late Future<List<Post>> _userPostsFuture;
  bool _isLoading = false;
  int _selectedTab = 0; // 0 for Pets, 1 for Posts

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _userPetsFuture = _petService.getPets(userId: widget.userId);
    _userPostsFuture = _postService.getUserPosts(widget.userId);
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pets = await _petService.getPets(userId: widget.userId);
      final posts = await _postService.getUserPosts(widget.userId);
      setState(() {
        _userPetsFuture = Future.value(pets);
        _userPostsFuture = Future.value(posts);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}\'s Profile'),
      ),
      body: Column(
        children: [
          // User info header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.orange[50],
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<List<Pet>>(
                      future: _userPetsFuture,
                      builder: (context, snapshot) {
                        final petCount = snapshot.hasData ? snapshot.data!.length : 0;
                        return FutureBuilder<List<Post>>(
                          future: _userPostsFuture,
                          builder: (context, postSnapshot) {
                            final postCount = postSnapshot.hasData ? postSnapshot.data!.length : 0;
                            return Text(
                              '$petCount pets • $postCount posts',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab selection
          Container(
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(0, 'Pets', Icons.pets),
                ),
                Expanded(
                  child: _buildTabButton(1, 'Posts', Icons.article),
                ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: _selectedTab == 0
                  ? _buildPetsContent()
                  : _buildPostsContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int tabIndex, String label, IconData icon) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedTab = tabIndex;
        });
      },
      style: TextButton.styleFrom(
        foregroundColor: _selectedTab == tabIndex ? Colors.orange : Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPetsContent() {
    return FutureBuilder<List<Pet>>(
      future: _userPetsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('pets', Icons.pets);
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final pet = snapshot.data![index];
              return _buildPetCard(pet);
            },
          );
        }
      },
    );
  }

  Widget _buildPostsContent() {
    return FutureBuilder<List<Post>>(
      future: _userPostsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('posts', Icons.article);
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];
              return _buildPostCard(post);
            },
          );
        }
      },
    );
  }

  Widget _buildEmptyState(String type, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'No $type yet',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.userName} hasn\'t created any $type',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            pet.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[200],
              child: const Icon(Icons.pets),
            ),
          ),
        ),
        title: Text(
          pet.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${pet.breed} • ${pet.age} years'),
        trailing: Chip(
          label: Text(pet.gender),
          backgroundColor: Colors.orange[50],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          post.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              post.body.length > 100
                  ? '${post.body.substring(0, 100)}...'
                  : post.body,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(post.categoryName),
                  backgroundColor: Colors.blue[50],
                ),
                const SizedBox(width: 8),
                Text(
                  '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}