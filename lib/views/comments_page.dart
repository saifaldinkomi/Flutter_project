import 'package:flutter/material.dart';
import 'package:saif_final/models/coment_model.dart';
import 'package:saif_final/view_models/comment_service.dart';

class CommentsPage extends StatefulWidget {
  final String token;
  final int courseId;
  final int sectionId;
  final int postId;

  const CommentsPage({
    super.key,
    required this.token,
    required this.courseId,
    required this.sectionId,
    required this.postId,
  });

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late Future<List<Comment>> _commentsFuture;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
     _refreshComments();
  }

  void _refreshComments() {
    setState(() {
      _commentsFuture = CommentService.getComments(
        widget.token,
        widget.courseId,
        widget.sectionId,
        widget.postId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Comment>>(
        future: _commentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final comments = snapshot.data ?? [];
          if (comments.isEmpty) {
            return const Center(child: Text("No comments available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              
              final commentId = comment.id;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            comment.author,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comment.body,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 20),
                      Row(
                        children: [
                          FutureBuilder<bool>(
                            future: CommentService.getCommentLikeStatus(
                              widget.token,
                              widget.courseId,
                              widget.sectionId,
                              widget.postId,
                              commentId,
                            ),
                            builder: (context, likeSnapshot) {
                              if (likeSnapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              final isLiked = likeSnapshot.data ?? false;
                              return IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.grey,
                                ),
                                onPressed: () async {
                                  try {
                                    await CommentService.toggleLike(
                                      widget.token,
                                      widget.courseId,
                                      widget.sectionId,
                                      widget.postId,
                                      commentId,
                                    );
                                    _refreshComments();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("Failed to toggle like: $e")),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          FutureBuilder<int>(
                            future: CommentService.getCommentLikesCount(
                              widget.token,
                              widget.courseId,
                              widget.sectionId,
                              widget.postId,
                              commentId,
                            ),
                            builder: (context, likeCountSnapshot) {
                              if (likeCountSnapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              final likeCount = likeCountSnapshot.data ?? 0;
                              return Text(
                                "$likeCount Likes",
                                style: const TextStyle(fontSize: 14),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final newBody = await showDialog<String?>(
                                context: context,
                                builder: (context) {
                                  final controller = TextEditingController(text: comment.body);
                                  return AlertDialog(
                                    title: const Text("Edit Comment"),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                          hintText: "Enter new comment"),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(controller.text),
                                        child: const Text("Update"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (newBody != null && newBody.isNotEmpty) {
                                try {
                                  await CommentService.editComment(
                                    widget.token,
                                    widget.courseId,
                                    widget.sectionId,
                                    widget.postId,
                                    newBody,
                                    commentId,
                                  );
                                  _refreshComments();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Comment updated successfully")),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Failed to update comment: $e")),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Delete Comment"),
                                    content: const Text(
                                        "Are you sure you want to delete this comment?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text("Delete",
                                            style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (shouldDelete ?? false) {
                                try {
                                  await CommentService.deleteComment(
                                    widget.token,
                                    widget.courseId,
                                    widget.sectionId,
                                    widget.postId,
                                    commentId,
                                  );
                                  _refreshComments();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Comment deleted successfully")),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Failed to delete comment: $e")),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
     
      
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () async {
                    final commentText = _commentController.text.trim();

                    if (commentText.isNotEmpty) {
                      try {
                        await CommentService.addComment(
                          widget.token,
                          widget.courseId,
                          widget.sectionId,
                          widget.postId,
                          commentText,
                        );
                        _refreshComments();
                        _commentController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Comment added successfully")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to add comment: $e")),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
