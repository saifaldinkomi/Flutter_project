class CourseSubscription {
  final String id;
  final String courseName;
  final String sectionName;
  final String lecturer;
  final String collegeName;
  final String subscriptionDate;

  CourseSubscription({
    required this.id,
    required this.courseName,
    required this.sectionName,
    required this.lecturer,
    required this.collegeName,
    required this.subscriptionDate,
  });

  factory CourseSubscription.fromJson(Map<String, dynamic> json) {
    return CourseSubscription(
      id: json['id'].toString(),
      courseName: json['course'] ?? 'N/A',
      sectionName: json['section'] ?? 'N/A',
      lecturer: json['lecturer'] ?? 'N/A',
      collegeName: "College of IT",
      subscriptionDate: json['subscription_date'] ?? 'N/A',
    );
  }
}
