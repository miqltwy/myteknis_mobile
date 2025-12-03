import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';
import 'laporan.dart';
import 'riwayat.dart';
import 'models/model_detail.dart'; // Import Model
import 'services/booking_service.dart'; // Import Service

PageRoute<T> noAnimRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}

class DetailPesananPage extends StatefulWidget {
  final String idBooking;

  const DetailPesananPage({super.key, required this.idBooking});

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  DetailBookingModel? _detail;
  bool _isLoading = true;
  String? _errorMessage;
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final data = await _bookingService.getDetailBooking(widget.idBooking);
      setState(() {
        _detail = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double w = mq.size.width;
    final double h = mq.size.height;
    final double textScale = mq.textScaler.scale(1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEFE0),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: h * 0.06),

            // 🔹 AppBar custom
            Padding(
              padding: EdgeInsets.only(
                left: w * 0.04,
                right: w * 0.04,
                top: h * 0.02,
                bottom: h * 0.01,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8FA190),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Detail Pesanan',
                        style: TextStyle(
                          fontSize: 18 * textScale,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            SizedBox(height: h * 0.01),

            // 🔹 ISI DETAIL
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                  : Column(
                children: [
                  // PANEL PUTIH DETAIL
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.06,
                      vertical: h * 0.02,
                    ),
                    child: Column(
                      children: [
                        _buildRow('no. pesanan', _detail!.noTiket, textScale),
                        _buildRow('pembuat pesanan', _detail!.pembuat, textScale),
                        _buildRow('alamat', _detail!.alamat, textScale),
                        _buildRow('jenis permasalahan', _detail!.jenisPermasalahan, textScale),
                        _buildRow('status', _detail!.status, textScale, isStatus: true),
                        _buildRow('keterangan masalah', _detail!.keterangan, textScale),
                      ],
                    ),
                  ),

                  // AREA BAWAH + "Kirim Laporan"
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black54, width: 0.6),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.06,
                        vertical: h * 0.015,
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              noAnimRoute(
                                  KirimLaporanPage(idBooking: widget.idBooking)
                              ),
                            );
                          },
                          child: Text(
                            'Kirim Laporan',
                            style: TextStyle(
                              fontSize: 14 * textScale,
                              color: Colors.black87,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
      ),
    );
  }

  // Helper Widget untuk Baris Data
  Widget _buildRow(String label, String value, double textScale, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL KIRI
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13 * textScale,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // VALUE KANAN
          Expanded(
            flex: 5,
            child: isStatus
                ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(value),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11 * textScale,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
                : Text(
              value,
              style: TextStyle(
                fontSize: 13 * textScale,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai': return Colors.green;
      case 'dalam antrian': return const Color(0xFF4AAAF0);
      case 'diproses': return Colors.orange;
      default: return Colors.grey;
    }
  }
}