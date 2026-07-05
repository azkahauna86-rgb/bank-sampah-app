import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sampah_model.dart';

class SampahService {
  final _db = FirebaseFirestore.instance;

  Stream<List<SampahModel>> getSampahList() {
    return _db.collection('jenis_sampah').snapshots().map((snap) =>
        snap.docs.map((d) => SampahModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> tambahSampah(SampahModel sampah) async {
    await _db.collection('jenis_sampah').add(sampah.toMap());
  }

  Future<void> updateSampah(SampahModel sampah) async {
    await _db.collection('jenis_sampah').doc(sampah.id).update(sampah.toMap());
  }

  Future<void> hapusSampah(String id) async {
    await _db.collection('jenis_sampah').doc(id).delete();
  }
}