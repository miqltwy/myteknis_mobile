import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import ini
import 'package:untitled3/models/model_login.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.7:3000/api/login';

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'app_role': 'teknisi'
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        LoginResponse result = LoginResponse.fromJson(data);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result.token);
        await prefs.setInt('id', result.id);
        await prefs.setString('email', result.email);
        await prefs.setString('role', result.role);

        return result;
      } else {
        throw Exception(data['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data sesi
  }
}