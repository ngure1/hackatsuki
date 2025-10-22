//const String baseUrl = 'http://10.0.2.2:8080';
const String baseUrl = 'http://127.0.0.1:8080';

class ApiEndpoints {
  static const String backEndUrl = baseUrl;
  static const String chats = '$baseUrl/chats/';
  static String diagnosis(String chatId) => '$baseUrl/chats/$chatId/diagnosis/';
  static const String getPosts = '$baseUrl/posts/';
  static const String newPost = '$baseUrl/posts/';
  static String getPost(String postId) => '$baseUrl/$postId/';
  static String likePost(String postId) => '$baseUrl/posts/$postId/likes/';
  static String addComment(String postId) => '$baseUrl/posts/$postId/comments/';
  static String getPostComments(String postId) => '$baseUrl/posts/$postId/comments/';
  static String getCommentReplies(String commentId) =>
      '$baseUrl/comments/$commentId/replies/';
}
