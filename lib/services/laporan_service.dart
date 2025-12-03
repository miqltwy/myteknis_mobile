import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LaporanService {
  static const String _baseUrl = 'http://192.168.1.7:3000/api/teknisi';

  Future<bool> kirimLaporan({
    required String idBooking,
    required String catatan,
    required List<File> images,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) throw Exception('Token invalid');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/buat-laporan'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['booking_id'] = idBooking;
      request.fields['catatan'] = catatan;

      // File Images (sesuai upload.array("foto_bukti", 3))
      for (var image in images) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();

        var multipartFile = http.MultipartFile(
          'foto_bukti', // Key harus sama persis dengan backend middleware
          stream,
          length,
          filename: image.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Kirim Request
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == true) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'Gagal mengirim laporan');
      }
    } catch (e) {
      throw Exception('Error Service: $e');
    }
  }
}