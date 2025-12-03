import 'package:flutter/material.dart';
// Import halaman-halaman tujuan
import '../beranda.dart';
import '../riwayat.dart';
import '../login.dart'; // Untuk kembali ke MyApp saat logout
import '../services/auth_service.dart'; // Untuk fungsi logout

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  // HAPUS: final ValueChanged<int> onItemSelected;
  // Kita tidak butuh ini lagi karena logic ada di dalam sini

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  // 🔹 LOGIKA NAVIGASI TERPUSAT DISINI
  void _onItemTapped(BuildContext context, int index) {
    // 1. Jika menekan tombol yang sama dengan halaman aktif, jangan lakukan apa-apa
    if (index == currentIndex) return;

    // 2. Logika Pindah Halaman
    switch (index) {
      case 0:
      // Ke Beranda (Reset Stack agar bersih)
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HelloPage(),
            transitionDuration: Duration.zero,
          ),
              (route) => false,
        );
        break;

      case 1:
      // Ke Riwayat (Bisa pakai pushReplacement atau pushAndRemoveUntil)
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const RiwayatPage(),
            transitionDuration: Duration.zero,
          ),
              (route) => false, // Reset stack biar user gak bisa 'Back' bolak-balik
        );
        break;

      case 2:
      // 3. Logika Logout (Terpusat)
        _handleLogout(context);
        break;
    }
  }

  // 🔹 LOGIKA LOGOUT TERPUSAT
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog

                // Panggil Service Logout
                await AuthService().logout(); // Pastikan method ini ada & static/singleton

                if (!context.mounted) return;

                // Kembali ke Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                      (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double w = mq.size.width;
    final double textScale = mq.textScaler.scale(1.0);

    return Container(
      width: w,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 10,
        bottom: mq.padding.bottom + 6,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF819A91),
        borderRadius: BorderRadius.only(
          // topLeft: Radius.circular(10),
          // topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Beranda',
            isActive: currentIndex == 0,
            textScale: textScale,
            onTap: () => _onItemTapped(context, 0), // PANGGIL FUNGSI INTERNAL
          ),
          _NavItem(
            icon: Icons.history_rounded,
            label: 'Riwayat',
            isActive: currentIndex == 1,
            textScale: textScale,
            onTap: () => _onItemTapped(context, 1), // PANGGIL FUNGSI INTERNAL
          ),
          _NavItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            isActive: currentIndex == 2,
            textScale: textScale,
            onTap: () => _onItemTapped(context, 2), // PANGGIL FUNGSI INTERNAL
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final double textScale;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.textScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color baseColor = Color(0xFFF4F5E9); // krem

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? baseColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive
                  ? const Color(0xFF7D8C82)
                  : baseColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11 * textScale,
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }
}
