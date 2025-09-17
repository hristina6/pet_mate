// import 'package:flutter/material.dart';
// import '../services/post_service.dart';
// import '../models/category.dart';
// import './category_posts_screen.dart';
//
// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({super.key});
//
//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }
//
// class _CategoriesScreenState extends State<CategoriesScreen> {
//   final PostService _postService = PostService();
//   List<Category> _categories = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }
//
//   Future<void> _loadCategories() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
//
//     try {
//       final categories = await _postService.getCategories();
//       setState(() {
//         _categories = categories;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load categories: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadCategories,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage.isNotEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               _errorMessage,
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.red),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadCategories,
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       )
//           : _categories.isEmpty
//           ? const Center(
//         child: Text('No categories found'),
//       )
//           : ListView.builder(
//         itemCount: _categories.length,
//         itemBuilder: (context, index) {
//           final category = _categories[index];
//           return Card(
//             margin: const EdgeInsets.all(8.0),
//             child: ListTile(
//               leading: const Icon(Icons.category),
//               title: Text(
//                 category.name,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               subtitle: category.description != null
//                   ? Text(category.description!)
//                   : null,
//               trailing: const Icon(Icons.arrow_forward),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CategoryPostsScreen(
//                       category: category,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }