import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saif_final/models/post_model.dart';

class PostService {
  static const String baseUrl = "http://feeds.ppu.edu/api/v1/courses";

  static Future<List<Post>> getPosts(
      String token, int courseId, int sectionId) async {
    final url = "$baseUrl/$courseId/sections/$sectionId/posts";
    final response =
        await http.get(Uri.parse(url), headers: {"Authorization": token});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['posts'];
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts: ${response.body}');
    }
  }

  static Future<Post> addPost(
      String token, int courseId, int sectionId, String content) async {
    final url = "$baseUrl/$courseId/sections/$sectionId/posts";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": token,
        "Content-Type": "application/json",
      },
      body: jsonEncode({"body": content}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Post.fromJson({
        'id': data['post_id'] ?? 0,
        'author': 'You',
        'body': content,
        'date_posted': DateTime.now().toString(),
      });
    } else {
      throw Exception('Failed to add post: ${response.body}');
    }
  }

  static Future<Post> editPost(String token, int courseId, int sectionId,
      int postId, String content) async {
    final url = "$baseUrl/$courseId/sections/$sectionId/posts/$postId";
    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Authorization": token,
        "Content-Type": "application/json",
      },
      body: jsonEncode({"body": content}),
    );

    if (response.statusCode == 200) {
      // final Map<String, dynamic> data = jsonDecode(response.body);
      return Post.fromJson({
        'id': postId, 
        'author': 'You',
        'body': content,
        'date_posted': DateTime.now().toString(),
      });
    } else {
      throw Exception('Failed to edit post: ${response.body}');
    }
  }
}
