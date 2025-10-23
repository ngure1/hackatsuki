class User {
  final int? id;
  final String firstName;
  final String lastName;

  User({this.id, required this.firstName, required this.lastName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}