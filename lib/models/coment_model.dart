class Comment {
  final int id;
  final String body;
  final String author;
  final DateTime createdAt;
  final bool liked;
  final int likesCount;

  Comment({
    required this.id,
    required this.body,
    required this.author,
    required this.createdAt,
    required this.liked,
    required this.likesCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      author: json['author'] ?? 'Unknown',
      createdAt: json['created_at'] ?? DateTime.now(),
      liked: json['liked'] ?? false,
      likesCount: json['likes_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'author': author,
      'created_at': createdAt.toIso8601String(),
      'liked': liked,
      'likes_count': likesCount,
    };
  }
}