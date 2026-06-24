class SampahModel {
  final String id;
  final String nama;
  final String satuan;
  final double hargaPerSatuan;
  final String kategori;

  SampahModel({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.hargaPerSatuan,
    required this.kategori,
  });

  factory SampahModel.fromMap(Map<String, dynamic> map, String id) {
    return SampahModel(
      id: id,
      nama: map['nama'] ?? '',
      satuan: map['satuan'] ?? 'kg',
      hargaPerSatuan: (map['hargaPerSatuan'] ?? 0).toDouble(),
      kategori: map['kategori'] ?? 'Umum',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'satuan': satuan,
      'hargaPerSatuan': hargaPerSatuan,
      'kategori': kategori,
    };
  }
}