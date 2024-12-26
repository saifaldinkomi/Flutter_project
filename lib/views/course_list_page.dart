import 'package:flutter/material.dart';
import 'package:saif_final/view_models/course_view_model.dart';
import 'package:saif_final/views/Post_page.dart';
import 'package:saif_final/views/drawer.dart';

class CourseList extends StatefulWidget {
  final String token;

  const CourseList({super.key, required this.token});

  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  final CourseViewModel _courseModel = CourseViewModel();
  List<dynamic> courses = [];
  Map<int, List<dynamic>> sections = {};
  Map<int, Map<String, dynamic>> sectionSubscriptions = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _loadSubscriptions();
  }

  Future<void> _loadCourses() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedCourses = await _courseModel.getCourses(widget.token);
      setState(() {
        courses = fetchedCourses;
      });
    } catch (e) {
      _showErrorDialog('Error loading courses: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadSections(int courseId) async {
    try {
      final fetchedSections = await _courseModel.getSections(widget.token, courseId);
      setState(() {
        sections[courseId] = fetchedSections;
      });
    } catch (e) {
      _showErrorDialog('Error loading sections: $e');
    }
  }

  Future<void> _loadSubscriptions() async {
    try {
      final fetchedSubscriptions = await _courseModel.getSubscriptions(widget.token);
      setState(() {
        sectionSubscriptions = fetchedSubscriptions;
      });
    } catch (e) {
      _showErrorDialog('Error loading subscriptions: $e');
    }
  }

  Future<void> _subscribe(int courseId, int sectionId) async {
    try {
      await _courseModel.subscribeSection(widget.token, courseId, sectionId);
      await _loadSubscriptions();
    } catch (e) {
      _showErrorDialog('Error subscribing: $e');
    }
  }

  Future<void> _unsubscribe(int courseId, int sectionId) async {
    final subscriptionId = sectionSubscriptions[sectionId]?['subscription_id'];
    if (subscriptionId != null) {
      try {
        await _courseModel.unsubscribeSection(widget.token, courseId, sectionId, subscriptionId);
        await _loadSubscriptions();
      } catch (e) {
        _showErrorDialog('Error unsubscribing: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses"),
      ),
      drawer: DrowerPage(token: widget.token),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? const Center(child: Text("No courses available"))
              : ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    final courseId = course['id'];
                    final courseSections = sections[courseId] ?? [];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Text(course['name']),
                        subtitle: Text("College: ${course['college']}"),
                        onExpansionChanged: (expanded) {
                          if (expanded && sections[courseId] == null) {
                            _loadSections(courseId);
                          }
                        },
                        children: courseSections.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("No sections available."),
                                ),
                              ]
                            : courseSections.map((section) {
                                final sectionId = section['id'];
                                final isSubscribed =
                                    sectionSubscriptions.containsKey(sectionId);

                                return ListTile(
                                  title: Text("Section: ${section['name']}"),
                                  subtitle: Text("Lecturer: ${section['lecturer']}"),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isSubscribed
                                          ? Icons.remove_circle
                                          : Icons.add_circle,
                                      color: isSubscribed ? Colors.red : Colors.green,
                                    ),
                                    onPressed: () {
                                      if (isSubscribed) {
                                        _unsubscribe(courseId, sectionId);
                                      } else {
                                        _subscribe(courseId, sectionId);
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PostPage(
                                          courseId: courseId,
                                          sectionId: sectionId,
                                          token: widget.token,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                      ),
                    );
                  },
                ),
    );
  }
}
