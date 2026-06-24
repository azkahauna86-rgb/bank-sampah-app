import 'package:cloud_firestore/cloud_firestore.dart';

class TransaksiModel {
  final String id;
  final String userId;
  final String userNama;
  final String sampahId;
  final String sampahNama;
  final double berat;
  final double totalHarga;
  final int poinDapat;
  final String status;
  final DateTime tanggal;
  final double? lokasiLat;
  final double? lokasiLng;
  final String? alamatPenjemputan;

  TransaksiModel({
    required this.id,
    required this.userId,
    required this.userNama,
    required this.sampahId,
    required this.sampahNama,
    required this.berat,
    required this.totalHarga,
    required this.poinDapat,
    required this.status,
    required this.tanggal,
    this.lokasiLat,
    this.lokasiLng,
    this.alamatPenjemputan,
  });

  factory TransaksiModel.fromMap(Map<String, dynamic> map, String id) {
    return TransaksiModel(
      id: id,
      userId: map['userId'] ?? '',
      userNama: map['userNama'] ?? '',
      sampahId: map['sampahId'] ?? '',
      sampahNama: map['sampahNama'] ?? '',
      berat: (map['berat'] ?? 0).toDouble(),
      totalHarga: (map['totalHarga'] ?? 0).toDouble(),
      poinDapat: (map['poinDapat'] ?? 0).toInt(),
      status: map['status'] ?? 'pending',
      tanggal: (map['tanggal'] as Timestamp).toDate(),
      lokasiLat: (map['lokasiLat'] as num?)?.toDouble(),
      lokasiLng: (map['lokasiLng'] as num?)?.toDouble(),
      alamatPenjemputan: map['alamatPenjemputan'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userNama': userNama,
      'sampahId': sampahId,
      'sampahNama': sampahNama,
      'berat': berat,
      'totalHarga': totalHarga,
      'poinDapat': poinDapat,
      'status': status,
      'tanggal': Timestamp.fromDate(tanggal),
      'lokasiLat': lokasiLat,
      'lokasiLng': lokasiLng,
      'alamatPenjemputan': alamatPenjemputan,
    };
  }
}