class LoginResponse {
  final String token;
  final int id;
  final String email;
  final String role;

  LoginResponse({
    required this.token,
    required this.id,
    required this.email,
    required this.role,
  });

  // Factory untuk mengubah JSON dari backend menjadi Object Dart
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}