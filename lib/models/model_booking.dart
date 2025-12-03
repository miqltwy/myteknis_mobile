class BookingModel {
  final int idBooking;
  final String nama;
  final String kode;
  final String permasalahan;
  final String status;

  BookingModel({
    required this.idBooking,
    required this.nama,
    required this.kode,
    required this.permasalahan,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      idBooking: json['id_booking'] ?? 0, // MAP DARI JSON
      nama: json['Kantor'] ?? 'Tanpa Nama',
      kode: json['no_tiket'] ?? '-',
      permasalahan: json['Kategori'] ?? '-',
      status: json['status'] ?? 'pending',
    );
  }
}