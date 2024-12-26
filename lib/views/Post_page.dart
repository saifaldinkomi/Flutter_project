import 'package:flutter/material.dart';
import 'package:saif_final/models/post_model.dart';
import 'package:saif_final/view_models/Post_service.dart';
import 'package:saif_final/views/comments_page.dart';
import 'package:saif_final/views/drawer.dart';

class PostPage extends StatefulWidget {
  final String token;
  final int courseId;
  final int sectionId;

  const PostPage({
    Key? key,
    required this.token,
    required this.courseId,
    required this.sectionId,
  }) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool isLoading = false;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      posts = await PostService.getPosts(
          widget.token, widget.courseId, widget.sectionId);
    } catch (e) {
      print("Error fetching posts: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addPost(String content) async {
    if (content.trim().isEmpty) return;
    try {
      final newPost = await PostService.addPost(
          widget.token, widget.courseId, widget.sectionId, content);
      setState(() {
        posts.insert(0, newPost);
      });
    } catch (e) {
      print("Error adding post: $e");
    }
  }

  Future<void> editPost(int postId, String content) async {
    if (content.trim().isEmpty) return;
    try {
      final updatedPost = await PostService.editPost(
          widget.token, widget.courseId, widget.sectionId, postId, content);
      setState(() {
        final index = posts.indexWhere((post) => post.id == postId);
        if (index != -1) posts[index] = updatedPost;
      });
    } catch (e) {
      print("Error editing post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Page"),
      ),
      drawer: DrowerPage(token: widget.token),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(child: Text("No posts available"))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(post.author),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.body),
                            const SizedBox(height: 8),
                            Text("Posted on: ${post.datePosted}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDialog(context, post),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentsPage(
                                token: widget.token,
                                courseId: widget.courseId,
                                sectionId: widget.sectionId,
                                postId: post.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPostDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Post"),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: "Enter your post content"),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              addPost(controller.text);
              Navigator.of(context).pop();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Post post) {
    final TextEditingController controller =
        TextEditingController(text: post.body);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Post"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Edit your post content"),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              editPost(post.id, controller.text);
              Navigator.of(context).pop();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
