import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saif_final/views/drawer.dart';
import 'package:saif_final/views/course_detail_page.dart';
import 'package:saif_final/models/course_subscription_model.dart';

class SubscribedCoursesPage extends StatefulWidget {
  final String token;

  const SubscribedCoursesPage({super.key, required this.token});

  @override
  _SubscribedCoursesPageState createState() => _SubscribedCoursesPageState();
}

class _SubscribedCoursesPageState extends State<SubscribedCoursesPage> {
  List<CourseSubscription> courseSubscriptions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    String subscriptionsUrl = "http://feeds.ppu.edu/api/v1/subscriptions";

    try {
      final response = await http.get(
        Uri.parse(subscriptionsUrl),
        headers: {"Authorization": widget.token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['subscriptions'] != null) {
          setState(() {
            courseSubscriptions = List<CourseSubscription>.from(
              data['subscriptions']
                  .map((sub) => CourseSubscription.fromJson(sub)),
            );
          });
        } else {
          setState(() {
            courseSubscriptions = [];
            errorMessage = "No subscriptions found!";
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to fetch subscriptions. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching subscriptions: $e';
      });
    } finally {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subscribed Courses"),
      ),
      drawer: DrowerPage(token: widget.token),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : courseSubscriptions.isEmpty
                  ? Center(child: Text("No subscribed courses"))
                  : ListView.builder(
                      itemCount: courseSubscriptions.length,
                      itemBuilder: (context, index) {
                        final subscription = courseSubscriptions[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: Text("Course: ${subscription.courseName}"),
                            subtitle: Text(
                              "Section: ${subscription.sectionName} - Lecturer: ${subscription.lecturer}",
                            ),
                            trailing: Text(subscription.collegeName),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailPage(
                                    courseDetails: subscription,
                                    token: widget.token,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
