/// A posted comment from GitHub.
class PostedComment {
  const PostedComment({
    required this.id,
    required this.body,
  });

  factory PostedComment.fromJson(Map<String, dynamic> json) {
    return PostedComment(
      id: json['id'],
      body: json['body'],
    );
  }

  /// The comment id
  final int id;

  /// The contents of the comment.
  final String body;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostedComment && other.id == id && other.body == body;
  }

  @override
  int get hashCode => id.hashCode ^ body.hashCode;

  @override
  String toString() => 'PostedComment(id: $id, body: $body)';
}
