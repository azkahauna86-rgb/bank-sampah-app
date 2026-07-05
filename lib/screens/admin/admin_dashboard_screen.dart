import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'kelola_sampah_screen.dart';
import 'kelola_transaksi_screen.dart';
import 'admin_chat_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F4C3A), Color(0xFF1B7A4D), Color(0xFF2FA86B)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('ADMIN PANEL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 10),
                      const Text('Dashboard Admin ⚙️', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Kelola aplikasi bank sampah', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showLogoutDialog(context, auth),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('Menu Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B3B2C))),
                const SizedBox(height: 14),
                _AdminMenuTile(
                  icon: Icons.delete_sweep_rounded,
                  label: 'Kelola Jenis Sampah',
                  subtitle: 'Tambah, edit, hapus jenis sampah & harga',
                  gradientColors: const [Color(0xFF2FA86B), Color(0xFF1B7A4D)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaSampahScreen())),
                ),
                const SizedBox(height: 14),
                _AdminMenuTile(
                  icon: Icons.fact_check_rounded,
                  label: 'Kelola Transaksi',
                  subtitle: 'Setujui atau tolak pengajuan setor sampah',
                  gradientColors: const [Color(0xFF1976D2), Color(0xFF0D47A1)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaTransaksiScreen())),
                ),
                const SizedBox(height: 14),
                _AdminMenuTile(
                  icon: Icons.chat_rounded,
                  label: 'Pesan Masuk',
                  subtitle: 'Balas pesan dan pertanyaan dari user',
                  gradientColors: const [Color(0xFF7B1FA2), Color(0xFF4A148C)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatListScreen())),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun?'),
        content: const Text('Yakin mau logout dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2FA86B), foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _AdminMenuTile({required this.icon, required this.label, required this.subtitle, required this.gradientColors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B3B2C))),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 2),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}