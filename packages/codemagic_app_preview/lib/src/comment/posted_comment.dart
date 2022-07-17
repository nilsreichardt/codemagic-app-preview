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
}
