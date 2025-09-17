// import 'package:flutter/material.dart';
// import '../services/comment_service.dart';
// import '../models/comment.dart';
// import '../models/post.dart';
//
// class CommentsScreen extends StatefulWidget {
//   final Post post;
//
//   const CommentsScreen({super.key, required this.post});
//
//   @override
//   State<CommentsScreen> createState() => _CommentsScreenState();
// }
//
// class _CommentsScreenState extends State<CommentsScreen> {
//   final CommentService _commentService = CommentService();
//   final TextEditingController _contentController = TextEditingController();
//   late Future<List<Comment>> _commentsFuture;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _commentsFuture = _loadComments();
//   }
//
//   Future<List<Comment>> _loadComments() async {
//     return await _commentService.getComments(widget.post.id);
//   }
//
//   Future<void> _refreshComments() async {
//     setState(() {
//       _commentsFuture = _loadComments();
//     });
//   }
//
//   Future<void> _addComment() async {
//     if (_contentController.text.isEmpty) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     final success = await _commentService.createComment(
//       content: _contentController.text,
//       postId: widget.post.id,
//     );
//
//     if (success) {
//       _contentController.clear();
//       _refreshComments();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Comment added!')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to add comment')),
//       );
//     }
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Comments for "${widget.post.title}"')),
//       body: Column(
//         children: [
//           Expanded(
//             child: FutureBuilder<List<Comment>>(
//               future: _commentsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No comments yet'));
//                 } else {
//                   return RefreshIndicator(
//                     onRefresh: _refreshComments,
//                     child: ListView.builder(
//                       itemCount: snapshot.data!.length,
//                       itemBuilder: (context, index) {
//                         final comment = snapshot.data![index];
//                         return ListTile(
//                           title: Text(comment.userName),
//                           subtitle: Text(comment.content),
//                         );
//                       },
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _contentController,
//                     decoration: const InputDecoration(
//                       hintText: 'Add a comment...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 _isLoading
//                     ? const CircularProgressIndicator()
//                     : IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _addComment,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
