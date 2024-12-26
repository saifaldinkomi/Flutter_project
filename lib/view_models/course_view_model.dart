import 'dart:convert';
import 'package:http/http.dart' as http;

class CourseViewModel {
  final String url = "http://feeds.ppu.edu/api/v1";

  Future<List<dynamic>> getCourses(String token) async {
    final response = await http.get(
      Uri.parse("$url/courses"),
      headers: {"Authorization": token},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['courses'];
    } else {
      throw Exception('Failed to load courses: ${response.body}');
    }
  }

  Future<List<dynamic>> getSections(String token, int courseId) async {
    final response = await http.get(
      Uri.parse("$url/subscriptions/$courseId/sections"),
      headers: {"Authorization": token},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['sections'];
    } else {
      throw Exception('Failed to load sections: ${response.body}');
    }
  }

  Future<Map<int, Map<String, dynamic>>> getSubscriptions(String token) async {
    final response = await http.get(
      Uri.parse("$url/subscriptions"),
      headers: {"Authorization": token},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['subscriptions'];
      final Map<int, Map<String, dynamic>> subscriptions = {};
      for (var sub in data) {
        subscriptions[sub['section_id']] = {
          'course': sub['course'],
          'lecturer': sub['lecturer'],
          'subscription_id': sub['id'],
        };
      }
      return subscriptions;
    } else {
      throw Exception('Failed to load subscriptions: ${response.body}');
    }
  }

  Future<void> subscribeSection(
      String token, int courseId, int sectionId) async {
    final response = await http.post(
      Uri.parse("$url/courses/$courseId/sections/$sectionId/subscribe"),
      headers: {"Authorization": token},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to subscribe: ${response.body}');
    }
  }

  Future<void> unsubscribeSection(
      String token, int courseId, int sectionId, int subscriptionId) async {
    final response = await http.delete(
      Uri.parse(
          "$url/courses/$courseId/sections/$sectionId/subscribe/$subscriptionId"),
      headers: {"Authorization": token},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unsubscribe: ${response.body}');
    }
  }
}
