import 'package:flutter/material.dart';
import 'login.dart';
import 'widgets/custom_bottom_nav.dart';
import 'detailpesanan.dart';
import 'riwayat.dart';
import 'models/model_booking.dart'; // Import Model
import 'services/booking_service.dart';

PageRoute<T> noAnimRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}

class HelloPage extends StatefulWidget {
  const HelloPage({super.key});

  @override
  State<HelloPage> createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  int _currentIndex = 0;

  // 🔹 State untuk Data & Loading
  List<BookingModel> _bookings = [];
  String _namaTeknisi = 'Memuat...'; // Default loading state
  String _roleTeknisi = '';

  bool _isLoading = true;
  String? _errorMessage;
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // Fungsi mengambil data dari backend
  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _bookingService.getDashboardData();
      setState(() {
        _bookings = data['bookings'];
        _namaTeknisi = data['nama']; // Update nama dari backend
        _roleTeknisi = data['role']; // Update role dari backend
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _namaTeknisi = 'User'; // Fallback jika error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double w = mq.size.width;
    final double h = mq.size.height;
    final double textScale = mq.textScaler.scale(1.0);

    final bool hasBooking = _bookings.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFEEEFE0), // krem muda background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: h * 0.06,
            left: w * 0.06,
            right: w * 0.06,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔵 Profil atas
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF819A91),
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _namaTeknisi, // Bisa diganti dinamis dari SharedPref juga
                        style: TextStyle(
                          fontSize: 17 * textScale,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _roleTeknisi.isNotEmpty ? _roleTeknisi: 'Teknisi',
                        style: TextStyle(
                          fontSize: 13 * textScale,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: Colors.black54, thickness: 0.7),
              const SizedBox(height: 12),

              Expanded( // Menggunakan Expanded agar responsif mengisi sisa layar
                child: Container(
                  width: w * 0.88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA7C1A8),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.black26, width: 1),
                  ),
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 8,
                    bottom: 12, // Sesuaikan padding bawah
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Daftar Pesanan Hari Ini',
                        style: TextStyle(
                          fontSize: 15 * textScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // 🔹 List booking (Handling Loading & Error)
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : _errorMessage != null
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!.replaceAll('Exception: ', ''),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white),
                                onPressed: _fetchDashboardData,
                              )
                            ],
                          ),
                        )
                            : hasBooking
                            ? Scrollbar(
                          thumbVisibility: true,
                          child: RefreshIndicator(
                            onRefresh: _fetchDashboardData,
                            child: ListView.builder(
                              itemCount: _bookings.length,
                              itemBuilder: (context, index) {
                                final data = _bookings[index];
                                return _BookingCard(
                                  key: ValueKey(data.kode),
                                  textScale: textScale,
                                  idBooking: data.idBooking,
                                  nama: data.nama,
                                  kode: data.kode,
                                  permasalahan: data.permasalahan,
                                  status: data.status,
                                );
                              },
                            ),
                          ),
                        )
                            : const Center(
                          child: Text(
                            'Belum ada booking hari ini',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Beri sedikit jarak sebelum navbar jika perlu
              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),

      // 🔴 Bottom navigation bar dinamis
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 0,
      ),
    );
  }
}

/// 🧊 Widget 1 kartu booking (tanpa efek shadow)
class _BookingCard extends StatelessWidget {
  final double textScale;
  final int idBooking;
  final String nama;
  final String kode;
  final String permasalahan;
  final String status;

  const _BookingCard({
    super.key,
    required this.textScale,
    required this.idBooking,
    required this.nama,
    required this.kode,
    required this.permasalahan,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nama,
            style: TextStyle(
              fontSize: 15 * textScale,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 3),

          Text(
            'Kode Pesanan : $kode',
            style: TextStyle(
              fontSize: 12.5 * textScale,
              color: Colors.black87,
            ),
          ),
          Text(
            'Permasalahan : $permasalahan',
            style: TextStyle(
              fontSize: 12.5 * textScale,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 3),

          // 🔽 Status + Lihat Detail di kiri
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Status pesanan : ',
                    style: TextStyle(
                      fontSize: 12.5 * textScale,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status), // Warna dinamis
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11 * textScale,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => DetailPesananPage(idBooking: idBooking.toString()),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Text(
                  'Lihat Detail',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 12.5 * textScale,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper warna status sederhana
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai': return Colors.green;
      case 'dalam antrian': return const Color(0xFF4AAAF0);
      case 'diproses': return Colors.orange;
      default: return Colors.grey;
    }
  }
}