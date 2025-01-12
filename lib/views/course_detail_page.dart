import 'package:flutter/material.dart';
import 'package:saif_final/models/course_subscription_model.dart';
import 'package:saif_final/views/drawer.dart';

class CourseDetailPage extends StatelessWidget {
  final CourseSubscription courseDetails;
  final String token;

  const CourseDetailPage({
    super.key,
    required this.courseDetails,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseDetails.courseName),
      ),
      drawer: DrowerPage(token: token),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Course Name: ${courseDetails.courseName}"),
            Text("Section: ${courseDetails.sectionName}"),
            Text("Lecturer: ${courseDetails.lecturer}"),
            Text("College: ${courseDetails.collegeName}"),
            Text("Subscription Date: ${courseDetails.subscriptionDate}"),
          ],
        ),
      ),
    );
  }
}
