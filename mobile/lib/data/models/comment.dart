class Comment {
  final int? id;
  final String content;
  final String authorName;
  final String timePosted;
  final int? parentCommentId; 
  final List<Comment> replies; 
  final int repliesCount;
  final int userId;
  final int postId;

  Comment({
    this.id,
    required this.content,
    required this.authorName,
    required this.timePosted,
    this.parentCommentId,
    required this.replies,
    required this.repliesCount,
    required this.userId,
    required this.postId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      authorName: json['author_name'] ?? 'Unknown User',
      timePosted: json['time_posted'] ?? 'Recently',
      parentCommentId: json['parent_comment_id'],
      replies: (json['replies'] as List<dynamic>?)
          ?.map((reply) => Comment.fromJson(reply))
          .toList() ?? [],
      repliesCount: json['replies_count'] ?? 0,
      userId: json['user_id'],
      postId: json['post_id'],
    );
  }
  
  Comment copyWith({
    List<Comment>? replies,
  }) {
    return Comment(
      id: id,
      content: content,
      authorName: authorName,
      timePosted: timePosted,
      parentCommentId: parentCommentId,
      replies: replies ?? this.replies,
      repliesCount: repliesCount,
      userId: userId,
      postId: postId,
    );
  }
}