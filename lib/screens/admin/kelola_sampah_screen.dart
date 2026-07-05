import 'package:flutter/material.dart';
import '../../services/sampah_service.dart';
import '../../models/sampah_model.dart';

class KelolaSampahScreen extends StatefulWidget {
  const KelolaSampahScreen({super.key});
  @override
  State<KelolaSampahScreen> createState() => _KelolaSampahScreenState();
}

class _KelolaSampahScreenState extends State<KelolaSampahScreen> {
  final _service = SampahService();

  void _showFormDialog({SampahModel? sampah}) {
    final namaC = TextEditingController(text: sampah?.nama);
    final hargaC = TextEditingController(text: sampah?.hargaPerSatuan.toStringAsFixed(0));
    final satuanC = TextEditingController(text: sampah?.satuan ?? 'kg');
    final kategoriC = TextEditingController(text: sampah?.kategori ?? 'Umum');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                sampah == null ? 'Tambah Jenis Sampah' : 'Edit Jenis Sampah',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3B2C)),
              ),
              const SizedBox(height: 20),
              _FormField(controller: namaC, label: 'Nama Sampah', icon: Icons.label_outline_rounded),
              const SizedBox(height: 14),
              _FormField(controller: hargaC, label: 'Harga per Satuan (Rp)', icon: Icons.payments_outlined, isNumber: true),
              const SizedBox(height: 14),
              _FormField(controller: satuanC, label: 'Satuan (kg/pcs)', icon: Icons.straighten_rounded),
              const SizedBox(height: 14),
              _FormField(controller: kategoriC, label: 'Kategori', icon: Icons.category_outlined),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (namaC.text.isEmpty || hargaC.text.isEmpty) return;
                    final s = SampahModel(
                      id: sampah?.id ?? '',
                      nama: namaC.text,
                      hargaPerSatuan: double.tryParse(hargaC.text) ?? 0,
                      satuan: satuanC.text,
                      kategori: kategoriC.text,
                    );
                    if (sampah == null) {
                      await _service.tambahSampah(s);
                    } else {
                      await _service.updateSampah(s);
                    }
                    if (mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B7A4D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id, String nama) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Sampah?'),
        content: Text('Yakin mau hapus "$nama" dari daftar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              _service.hapusSampah(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      appBar: AppBar(
        title: const Text('Kelola Jenis Sampah', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B7A4D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: const Color(0xFF1B7A4D),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: StreamBuilder<List<SampahModel>>(
        stream: _service.getSampahList(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2FA86B)));
          }
          if (snap.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Belum ada jenis sampah', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text('Tap tombol + untuk menambahkan', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: snap.data!.length,
            itemBuilder: (ctx, i) {
              final s = snap.data![i];
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
                        gradient: const LinearGradient(colors: [Color(0xFF2FA86B), Color(0xFF1B7A4D)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.recycling_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 3),
                          Text('Rp ${s.hargaPerSatuan.toStringAsFixed(0)}/${s.satuan} • ${s.kategori}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF1976D2), size: 20),
                      onPressed: () => _showFormDialog(sampah: s),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_rounded, color: Colors.red.shade400, size: 20),
                      onPressed: () => _confirmDelete(s.id, s.nama),
                    ),
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

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNumber;

  const _FormField({required this.controller, required this.label, required this.icon, this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1B7A4D), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}