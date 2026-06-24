import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/transaksi_service.dart';
import '../../models/transaksi_model.dart';

class KelolaTransaksiScreen extends StatelessWidget {
  const KelolaTransaksiScreen({super.key});

  Future<void> _bukaLokasi(BuildContext context, double lat, double lng) async {
    final url = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng&zoom=16');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = TransaksiService();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      appBar: AppBar(
        title: const Text('Kelola Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B7A4D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<TransaksiModel>>(
        stream: service.getAllTransaksi(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2FA86B)));
          }
          if (snap.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fact_check_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Belum ada transaksi', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.length,
            itemBuilder: (ctx, i) {
              final t = snap.data![i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER: nama user + status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2FA86B).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_rounded, size: 16, color: Color(0xFF1B7A4D)),
                            ),
                            const SizedBox(width: 8),
                            Text(t.userNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        _StatusBadge(t.status),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // DETAIL TRANSAKSI
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4FBF6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _InfoRow('Jenis Sampah', t.sampahNama),
                          const SizedBox(height: 6),
                          _InfoRow('Berat', '${t.berat} kg'),
                          const SizedBox(height: 6),
                          _InfoRow('Total Harga', 'Rp ${t.totalHarga.toStringAsFixed(0)}'),
                          const SizedBox(height: 6),
                          _InfoRow('Poin', '${t.poinDapat} poin'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // LOKASI PENJEMPUTAN
                    if (t.lokasiLat != null && t.lokasiLng != null) ...[
                      GestureDetector(
                        onTap: () => _bukaLokasi(context, t.lokasiLat!, t.lokasiLng!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2FA86B), Color(0xFF1B7A4D)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Lokasi Penjemputan',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    Text(
                                      'Lat: ${t.lokasiLat!.toStringAsFixed(5)}, Lng: ${t.lokasiLng!.toStringAsFixed(5)}',
                                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // TIMESTAMP
                    Text(
                      DateFormat('dd MMM yyyy • HH:mm').format(t.tanggal),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),

                    // TOMBOL AKSI
                    if (t.status == 'pending') ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => service.updateStatusTransaksi(t.id, 'ditolak', t.userId, 0, 0),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text('Tolak'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade400,
                                side: BorderSide(color: Colors.red.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => service.updateStatusTransaksi(t.id, 'dijemput', t.userId, 0, 0),
                              icon: const Icon(Icons.directions_car_rounded, size: 18),
                              label: const Text('Jemput'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (t.status == 'dijemput') ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => service.updateStatusTransaksi(t.id, 'ditolak', t.userId, 0, 0),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text('Tolak'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade400,
                                side: BorderSide(color: Colors.red.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => service.updateStatusTransaksi(t.id, 'disetujui', t.userId, t.totalHarga, t.poinDapat),
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Setujui'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B7A4D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B3B2C))),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  Color get _color {
    switch (status) {
      case 'disetujui': return const Color(0xFF2FA86B);
      case 'ditolak': return Colors.red;
      case 'dijemput': return Colors.blue;
      default: return Colors.orange;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'disetujui': return Icons.check_circle_rounded;
      case 'ditolak': return Icons.cancel_rounded;
      case 'dijemput': return Icons.directions_car_rounded;
      default: return Icons.pending_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(status.toUpperCase(), style: TextStyle(color: _color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}