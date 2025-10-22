//const String baseUrl = 'http://10.0.2.2:8080';
const String baseUrl = 'http://127.0.0.1:8080';

class ApiEndpoints {
  static const String backEndUrl = baseUrl;
  static const String chats = '$baseUrl/chats/';
  static String getChatMessages(String chatId) => '$baseUrl/chats/$chatId/messages/';
  static String diagnosis(String chatId) => '$baseUrl/chats/$chatId/diagnosis/';
  static const String getPosts = '$baseUrl/posts/';
  static const String newPost = '$baseUrl/posts/';
  static String getPost(String postId) => '$baseUrl/$postId/';
  static String deletePost(String postId) => '$baseUrl/posts/$postId/';
  static String toggleLike(String postId) => '$baseUrl/posts/$postId/likes/';
  static String addComment(String postId) => '$baseUrl/posts/$postId/comments/';
  static String getPostComments(String postId) =>
      '$baseUrl/posts/$postId/comments/';
  static String getCommentReplies(String commentId) =>
      '$baseUrl/comments/$commentId/replies/';
  static const String getBlogs = '$baseUrl/blogs/';
  static const String newBlog = '$baseUrl/blogs/';
  static String getBlog(String blogId) => '$baseUrl/blogs/$blogId/';
  static String deleteBlog(String blogId) => '$baseUrl/blogs/$blogId/';
  static String getBlogComments(String blogId) =>
      '$baseUrl/blogs/$blogId/comments/';
  static String addBlogComment(String blogId) =>
      '$baseUrl/blogs/$blogId/comments/';
  static String toggleBlogLike(String blogId) =>
      '$baseUrl/blogs/$blogId/likes/';
  static String getBlogCommentReplies(String commentId) =>
      '$baseUrl/blog-comments/$commentId/replies/';
}
