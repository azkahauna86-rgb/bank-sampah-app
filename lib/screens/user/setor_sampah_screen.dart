import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../services/auth_service.dart';
import '../../services/sampah_service.dart';
import '../../services/transaksi_service.dart';
import '../../models/sampah_model.dart';
import '../../models/transaksi_model.dart';
import '../../widgets/location_picker.dart';

class SetorSampahScreen extends StatefulWidget {
  const SetorSampahScreen({super.key});
  @override
  State<SetorSampahScreen> createState() => _SetorSampahScreenState();
}

class _SetorSampahScreenState extends State<SetorSampahScreen> {
  final _sampahService = SampahService();
  final _transaksiService = TransaksiService();
  final _beratC = TextEditingController();
  SampahModel? _selected;
  String? _selectedId;
  bool _loading = false;
  String _filterKategori = 'Semua';
  LatLng? _lokasiPenjemputan;
  String _alamatPenjemputan = '';

  double get _estimasiTotal {
    if (_selected == null || _beratC.text.isEmpty) return 0;
    final berat = double.tryParse(_beratC.text) ?? 0;
    return berat * _selected!.hargaPerSatuan;
  }

  int get _estimasiPoin => (_estimasiTotal / 1000).floor();

  Future<void> _setor() async {
    if (_selected == null || _beratC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis sampah dan masukkan berat!')),
      );
      return;
    }
    if (_lokasiPenjemputan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih lokasi penjemputan di peta!')),
      );
      return;
    }
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get();
    final berat = double.parse(_beratC.text);

    final t = TransaksiModel(
      id: '',
      userId: auth.currentUser!.uid,
      userNama: userDoc['nama'],
      sampahId: _selected!.id,
      sampahNama: _selected!.nama,
      berat: berat,
      totalHarga: _estimasiTotal,
      poinDapat: _estimasiPoin,
      status: 'pending',
      tanggal: DateTime.now(),
      lokasiLat: _lokasiPenjemputan!.latitude,
      lokasiLng: _lokasiPenjemputan!.longitude,
      alamatPenjemputan: _alamatPenjemputan,
    );
    await _transaksiService.setorSampah(t);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Permintaan setor berhasil dikirim!'),
          backgroundColor: Color(0xFF2FA86B),
        ),
      );
      Navigator.pop(context);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
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
              title: const Text(
                'Setor Sampah',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionLabel('Kategori'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _FilterChip(
                      label: 'Semua',
                      selected: _filterKategori == 'Semua',
                      onTap: () => setState(() {
                        _filterKategori = 'Semua';
                        _selected = null;
                        _selectedId = null;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '🌱 Organik',
                      selected: _filterKategori == 'Organik',
                      onTap: () => setState(() {
                        _filterKategori = 'Organik';
                        _selected = null;
                        _selectedId = null;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '♻️ Non-Organik',
                      selected: _filterKategori == 'Non-Organik',
                      onTap: () => setState(() {
                        _filterKategori = 'Non-Organik';
                        _selected = null;
                        _selectedId = null;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _SectionLabel('Jenis Sampah'),
                const SizedBox(height: 10),
                StreamBuilder<List<SampahModel>>(
                  stream: _sampahService.getSampahList(),
                  builder: (ctx, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF2FA86B)));
                    }
                    if (snap.data!.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Colors.orange.shade700),
                            const SizedBox(width: 10),
                            const Expanded(child: Text('Belum ada jenis sampah, hubungi admin.')),
                          ],
                        ),
                      );
                    }
                    final filteredList = _filterKategori == 'Semua'
                        ? snap.data!
                        : snap.data!.where((s) => s.kategori == _filterKategori).toList();

                    if (filteredList.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_off_rounded, color: Colors.grey.shade500),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tidak ada jenis sampah kategori "$_filterKategori"',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedId,
                          isExpanded: true,
                          hint: const Text('Pilih jenis sampah'),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1B7A4D)),
                          items: filteredList.map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.nama} • Rp${s.hargaPerSatuan.toStringAsFixed(0)}/${s.satuan}'),
                          )).toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedId = v;
                              _selected = filteredList.firstWhere((s) => s.id == v);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),
                const _SectionLabel('Berat (kg)'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: TextField(
                    controller: _beratC,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 2.5',
                      prefixIcon: Icon(Icons.scale_rounded, color: Color(0xFF1B7A4D)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                if (_selected != null && _beratC.text.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2FA86B), Color(0xFF1B7A4D)]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: const Color(0xFF2FA86B).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimasi Pendapatan', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                            Text('Rp ${_estimasiTotal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: Colors.white24, height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimasi Poin', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                            Text('$_estimasiPoin Poin', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
                const _SectionLabel('Lokasi Penjemputan'),
                const SizedBox(height: 6),
                Text(
                  'Tap peta untuk pilih titik penjemputan, atau tap ikon 📍 untuk lokasi saat ini',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 10),
                LocationPicker(
                  onLocationSelected: (pos, address) {
                    setState(() {
                      _lokasiPenjemputan = pos;
                      _alamatPenjemputan = address;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _setor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B7A4D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Kirim Setoran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B3B2C)));
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? const LinearGradient(colors: [Color(0xFF2FA86B), Color(0xFF1B7A4D)]) : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade300),
          boxShadow: selected
              ? [BoxShadow(color: const Color(0xFF2FA86B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey.shade700),
        ),
      ),
    );
  }
}