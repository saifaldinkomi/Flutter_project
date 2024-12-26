
class CourseSubscription {
  final int id;
  final int sectionId;
  final String section;
  final String course;
  final String lecturer;
  final String subscriptionDate;

  CourseSubscription({
    required this.id,
    required this.sectionId,
    required this.section,
    required this.course,
    required this.lecturer,
    required this.subscriptionDate,
  });

  factory CourseSubscription.fromJson(Map<String, dynamic> json) {
    return CourseSubscription(
      id: json['id'] ?? 0,
      sectionId: json['section_id'] ?? 0,
      section: json['section'] ?? 'N/A',
      course: json['course'] ?? 'N/A',
      lecturer: json['lecturer'] ?? 'N/A',
      subscriptionDate: json['subscription_date'] ?? 'N/A',
    );
  }
}
