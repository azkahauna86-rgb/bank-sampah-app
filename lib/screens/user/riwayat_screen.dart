import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/transaksi_service.dart';
import '../../models/transaksi_model.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  Color _statusColor(String s) {
    if (s == 'disetujui') return const Color(0xFF2FA86B);
    if (s == 'ditolak') return Colors.red.shade400;
    return Colors.orange.shade600;
  }

  IconData _statusIcon(String s) {
    if (s == 'disetujui') return Icons.check_circle_rounded;
    if (s == 'ditolak') return Icons.cancel_rounded;
    return Icons.pending_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final transaksiService = TransaksiService();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            backgroundColor: const Color(0xFF1B7A4D),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Riwayat Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F4C3A), Color(0xFF1B7A4D), Color(0xFF2FA86B)],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<List<TransaksiModel>>(
            stream: transaksiService.getTransaksiUser(auth.currentUser!.uid),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF2FA86B))),
                );
              }
              if (snap.data!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Belum ada transaksi', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final t = snap.data![i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2FA86B).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.recycling_rounded, color: Color(0xFF1B7A4D)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.sampahNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${t.berat} kg • ${DateFormat('dd MMM yyyy', 'id_ID').format(t.tanggal)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rp ${t.totalHarga.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B3B2C)),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _statusColor(t.status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_statusIcon(t.status), size: 12, color: _statusColor(t.status)),
                                      const SizedBox(width: 4),
                                      Text(t.status, style: TextStyle(color: _statusColor(t.status), fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: snap.data!.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}