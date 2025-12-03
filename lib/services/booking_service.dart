import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model_booking.dart';
import '../models/model_detail.dart';
import '../models/model_riwayat.dart';

class BookingService {
  static const String _baseUrl = 'http://192.168.1.7:3000/api/teknisi';

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan, silakan login ulang');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/pesanan-terbaru'),
        headers: <String, String> {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        List<dynamic> listPesananRaw = data['pesanan'];
        List<BookingModel> listPesanan = listPesananRaw
            .map((e) => BookingModel.fromJson(e))
            .toList();

        String namaTeknisi = data['teknisi']?['username'] ?? 'Teknisi';
        String roleTeknisi = data['teknisi']?['role'] ?? 'Staff';

        return {
          'bookings': listPesanan,
          'nama': namaTeknisi,
          'role': roleTeknisi,
        };
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil data');
      }
    } catch (e) {
      throw Exception('Error Service: $e');
    }
  }

  Future<List<RiwayatModel>> getRiwayat() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) throw Exception('Token invalid');

      final response = await http.get(
        Uri.parse('$_baseUrl/riwayat-laporan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        List<dynamic> listRaw = data['riwayat'];
        return listRaw.map((e) => RiwayatModel.fromJson(e)).toList();
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception('Gagal memuat riwayat: $e');
    }
  }

  Future<DetailBookingModel> getDetailBooking(String idBooking) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) throw Exception('Token invalid');

      final response = await http.get(
        Uri.parse('$_baseUrl/detail-pesanan/$idBooking'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return DetailBookingModel.fromJson(data['detail']);
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception('Gagal memuat detail: $e');
    }
  }

}