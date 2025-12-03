class DetailBookingModel {
  final String noTiket;
  final String pembuat;
  final String alamat;
  final String jenisPermasalahan;
  final String status;
  final String keterangan;

  DetailBookingModel({
    required this.noTiket,
    required this.pembuat,
    required this.alamat,
    required this.jenisPermasalahan,
    required this.status,
    required this.keterangan,
  });

  factory DetailBookingModel.fromJson(Map<String, dynamic> json) {
    return DetailBookingModel(
      noTiket: json['no_tiket'] ?? '-',
      pembuat: json['Kantor'] ?? '-',
      alamat: json['alamat'] ?? '-',
      jenisPermasalahan: json['Kategori'] ?? '-',
      status: json['status'] ?? 'Pending',
      keterangan: json['deskripsi'] ?? '-',
    );
  }
}