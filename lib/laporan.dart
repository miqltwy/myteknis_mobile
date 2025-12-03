import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'widgets/custom_bottom_nav.dart';
import 'riwayat.dart';
import 'services/laporan_service.dart'; // Import Service

PageRoute<T> noAnimRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}

class KirimLaporanPage extends StatefulWidget {
  final String idBooking; // 1️⃣ TERIMA ID BOOKING

  const KirimLaporanPage({super.key, required this.idBooking});

  @override
  State<KirimLaporanPage> createState() => _KirimLaporanPageState();
}

class _KirimLaporanPageState extends State<KirimLaporanPage> {
  // 🔹 State Logic
  final TextEditingController _catatanController = TextEditingController();
  final LaporanService _bookingService = LaporanService();
  final ImagePicker _picker = ImagePicker();

  final List<File> _selectedImages = []; // Menyimpan gambar yang dipilih
  bool _isSubmitting = false;

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  // Fungsi Pilih Gambar
  Future<void> _pickImage() async {
    // Backend membatasi maksimal 3, jadi kita cek
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 3 foto bukti')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  // Fungsi Hapus Gambar (Opsional, UX lebih baik)
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Fungsi Submit
  Future<void> _submitLaporan() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap sertakan minimal 1 foto bukti')),
      );
      return;
    }
    if (_catatanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi keterangan')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _bookingService.kirimLaporan(
        idBooking: widget.idBooking, // Pakai ID dari widget
        catatan: _catatanController.text,
        images: _selectedImages,
      );

      if (!mounted) return;

      // Sukses -> Tampilkan pesan & Redirect ke Riwayat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim!'), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(
          context,
          noAnimRoute(const RiwayatPage())
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double w = mq.size.width;
    final double h = mq.size.height;
    final double textScale = mq.textScaler.scale(1.0);
    final bool isKeyboard = mq.viewInsets.bottom > 0;
    final double cardBottomPad = isKeyboard ? 12 : h * 0.09;

    return Scaffold(
      backgroundColor: const Color(0xFFEEEFE0),
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
          child: Column(
            children: [
              SizedBox(height: h * 0.06),

              // 🔹 AppBar
              Padding(
                padding: EdgeInsets.only(left: w * 0.04, right: w * 0.04, top: h * 0.02, bottom: h * 0.02),
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
                          'Kirim Laporan',
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

              // 🔹 KARTU FORM
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(left: w * 0.05, right: w * 0.05, bottom: cardBottomPad),
                  child: Center(
                    child: Container(
                      width: w * 0.9,
                      padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFB9B9B9), width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Foto Bukti (Maks 3)',
                            style: TextStyle(
                              fontSize: 15 * textScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 🔹 LOGIKA TAMPILAN KOTAK GAMBAR
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(3, (index) {
                              // Tentukan konten kotak berdasarkan index
                              if (index < _selectedImages.length) {
                                // Kotak berisi gambar yang sudah dipilih (Update)
                                return Stack(
                                  clipBehavior: Clip.none, // Agar tombol X bisa keluar dari kotak
                                  children: [
                                    Container(
                                      width: w * 0.18,
                                      height: w * 0.18,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        image: DecorationImage(
                                          image: FileImage(_selectedImages[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: -5, // Sesuaikan posisi X agar sedikit keluar
                                      top: -5,   // Sesuaikan posisi X agar sedikit keluar
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index), // Panggil fungsi hapus
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.red, // Warna merah agar menonjol
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5), // Border putih
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 12, // Ukuran ikon kecil
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else if (index == _selectedImages.length) {
                                // Kotak tombol tambah (+) (Sama seperti sebelumnya)
                                return GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: w * 0.18,
                                    height: w * 0.18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE4E4E4),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.add, size: 24, color: Colors.black87),
                                    ),
                                  ),
                                );
                              } else {
                                // Kotak kosong placeholder (Sama seperti sebelumnya)
                                return Container(
                                  width: w * 0.18,
                                  height: w * 0.18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }
                            }),
                          ),
                          const SizedBox(height: 20),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'keterangan',
                              style: TextStyle(fontSize: 13 * textScale, color: Colors.black87),
                            ),
                          ),

                          const SizedBox(height: 9),

                          // 🔹 INPUT TEXT CONTROLLER
                          SizedBox(
                            height: h * 0.20,
                            child: TextField(
                              controller: _catatanController, // HUBUNGKAN CONTROLLER
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(color: Color(0xFF7D8C82), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(color: Color(0xFF7D8C82), width: 1.2),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 🔹 TOMBOL SUBMIT
                          SizedBox(
                            width: w * 0.35,
                            height: 36,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF26A528),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                elevation: 0,
                              ),
                              onPressed: _isSubmitting ? null : _submitLaporan,
                              child: _isSubmitting
                                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(
                                'KIRIM',
                                style: TextStyle(
                                  fontSize: 14 * textScale,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
      ),
    );
  }
}