import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';
import 'models/model_riwayat.dart';
import 'services/booking_service.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<RiwayatModel> _riwayatList = [];
  bool _isLoading = true;
  String? _errorMessage;
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _bookingService.getRiwayat();
      setState(() {
        _riwayatList = data;
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
    final double h = mq.size.height;
    final double textScale = mq.textScaler.scale(1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEFE0),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: h * 0.06),

            // 🔹 AppBar Title
            Padding(
              padding: EdgeInsets.only(
                bottom: h * 0.02,
              ),
              child: Center(
                child: Text(
                  'Riwayat Laporan Pesanan',
                  style: TextStyle(
                    fontSize: 18 * textScale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // ❌ Divider DIHAPUS sesuai permintaan

            // 🔹 KONTEN LIST
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _fetchRiwayat,
                    )
                  ],
                ),
              )
                  : _riwayatList.isNotEmpty
                  ? ListView.separated(
                // ✅ Padding Horizontal dihapus agar card mentok kiri-kanan (100%)
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: h * 0.02,
                ),
                itemCount: _riwayatList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16), // Jarak antar card
                itemBuilder: (context, index) {
                  final item = _riwayatList[index];
                  return _RiwayatCard(
                    textScale: textScale,
                    data: item,
                  );
                },
              )
                  : Center(
                child: Text(
                  'Belum ada riwayat',
                  style: TextStyle(
                    fontSize: 14 * textScale,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 1,
      ),
    );
  }
}

/// =======================================================
/// 🟦 KARTU RIWAYAT (Full Width Style)
/// =======================================================
class _RiwayatCard extends StatelessWidget {
  final double textScale;
  final RiwayatModel data;

  const _RiwayatCard({
    required this.textScale,
    required this.data,
  });

  void _showImagePreview(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return const CircularProgressIndicator(color: Colors.white);
                },
                errorBuilder: (ctx, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.white, size: 50),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Agar isi konten tidak mepet layar, kita beri padding internal
    // Tapi containernya sendiri 100% width
    return Container(
      width: double.infinity, // Paksa lebar penuh
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Padding dalam
      decoration: const BoxDecoration(
        color: Colors.white,
        // ❌ Radius dihapus agar kotak sempurna
        // ✅ Border hanya di atas dan bawah
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Color(0xFFB9B9B9),
            width: 1,
          ),
        ),
        // Shadow opsional, jika ingin flat hapus saja boxShadow ini
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Column(
        children: [
          _buildRow('Kode pesanan', data.kode),
          const SizedBox(height: 8),
          _buildRow('Pembuat laporan', data.pembuat),
          const SizedBox(height: 8),
          _buildRow('Keterangan masalah', data.masalah),
          const SizedBox(height: 8),
          _buildRow('Catatan teknisi', data.catatan),
          const SizedBox(height: 8),

          _buildStatusRow('Status pesanan', data.status),
          const SizedBox(height: 12),

          _buildPhotoRow(context, 'File bukti', data.fotoBukti),
        ],
      ),
    );
  }

  // 🔹 Helper Row Biasa (Label - Value)
  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            '$label :',
            style: TextStyle(
              fontSize: 12 * textScale,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12 * textScale,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 Helper Row Status
  Widget _buildStatusRow(String label, String status) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            '$label :',
            style: TextStyle(
              fontSize: 12 * textScale,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13 * textScale,
                color: const Color(0xFF21A345),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Helper Row Foto (BARU: SUPPORT BANYAK FOTO)
  Widget _buildPhotoRow(BuildContext context, String label, List<String> photoUrls) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('$label :', style: _labelStyle()),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.centerRight,
            child: photoUrls.isNotEmpty
                ? Wrap( // 👈 Gunakan Wrap agar foto turun ke bawah jika > 1 baris
              spacing: 8, // Jarak horizontal antar foto
              runSpacing: 8, // Jarak vertikal jika ada baris baru
              alignment: WrapAlignment.end, // Rata kanan
              children: photoUrls.map((url) {
                return GestureDetector(
                  onTap: () => _showImagePreview(context, url),
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E4E4),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                        onError: (e, s) {},
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
                : const Text('-', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  // Styles shortcut
  TextStyle _labelStyle() => TextStyle(
    fontSize: 12 * textScale,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
}