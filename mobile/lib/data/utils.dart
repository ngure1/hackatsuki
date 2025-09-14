//const String baseUrl = 'http://10.0.2.2:8080';
const String baseUrl = 'http://127.0.0.1:8080';
class ApiEndpoints {
  static const String chats = '$baseUrl/chats/';
  static String diagnosis(String chatId) => '$baseUrl/chats/$chatId/diagnosis/';
}
