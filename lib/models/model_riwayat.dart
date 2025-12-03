class RiwayatModel {
  final String kode;
  final String pembuat;
  final String status;
  final String masalah;
  final String catatan;
  final List<String> fotoBukti;

  RiwayatModel({
    required this.kode,
    required this.pembuat,
    required this.status,
    required this.masalah,
    required this.catatan,
    required this.fotoBukti,
  });

  factory RiwayatModel.fromJson(Map<String, dynamic> json) {
  
    const String baseUrl = "http://192.168.1.7:3000/public/images/bukti/";

    List<String> urls = [];

    // Logika Baru: Ambil semua foto, split koma, lalu loop
    if (json['foto_bukti'] != null && (json['foto_bukti'] as String).isNotEmpty) {
      String rawPhotos = json['foto_bukti'];
      // Split berdasarkan koma, trim spasi, dan tambahkan base URL
      urls = rawPhotos.split(',').map((fileName) {
        return "$baseUrl${fileName.trim()}";
      }).toList();
    }

    return RiwayatModel(
      kode: json['no_tiket'] ?? '-',
      pembuat: json['Kantor'] ?? '-',
      status: json['status'] ?? 'Pending',
      masalah: json['deskripsi'] ?? '-',
      catatan: json['catatan'] ?? '-',
      fotoBukti: urls, // 👈 Masukkan List URL lengkap
    );
  }
}