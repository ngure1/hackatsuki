class UserDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const UserDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  factory UserDetails.empty() {
    return UserDetails(firstName: "", lastName: "", email: "", phoneNumber: "");
  }

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phoneNumber": phoneNumber,
    };
  }

  UserDetails copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) {
    return UserDetails(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
