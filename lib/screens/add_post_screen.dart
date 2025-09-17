import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../models/category.dart';

class AddPostScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const AddPostScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final PostService _postService = PostService();

  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _bodyController = TextEditingController();

  int? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _categoriesLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _categoriesLoading = true);

    try {
      final categories = await _postService.getCategories();
      setState(() => _categories = categories);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Failed to load categories: $e')),
      );
    } finally {
      setState(() => _categoriesLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      setState(() => _isLoading = true);

      try {
        final success = await _postService.createPost(
          title: _titleController.text.trim(),
          slug: _slugController.text.trim(),
          body: _bodyController.text.trim(),
          userId: widget.userId, // ✅ passes logged-in user ID
          categoryId: _selectedCategoryId!,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Post created successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Failed to create post')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please select a category')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Post Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Post Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter post title' : null,
                ),
                const SizedBox(height: 16),

                // Slug
                TextFormField(
                  controller: _slugController,
                  decoration: const InputDecoration(
                    labelText: 'Slug (URL-friendly name)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter slug';
                    }
                    if (value.contains(' ')) {
                      return 'Slug cannot contain spaces';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                _categoriesLoading
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((Category category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategoryId = value),
                  validator: (value) =>
                  value == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 16),

                // Body Content
                TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter content' : null,
                ),
                const SizedBox(height: 24),

                // Submit Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Create Post',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
