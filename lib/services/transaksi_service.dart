import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaksi_model.dart';

class TransaksiService {
  final _db = FirebaseFirestore.instance;

  Future<void> setorSampah(TransaksiModel t) async {
    await _db.collection('transaksi').add(t.toMap());
  }

  Stream<List<TransaksiModel>> getTransaksiUser(String userId) {
    return _db
        .collection('transaksi')
        .where('userId', isEqualTo: userId)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => TransaksiModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<TransaksiModel>> getAllTransaksi() {
    return _db
        .collection('transaksi')
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => TransaksiModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateStatusTransaksi(
    String id,
    String status,
    String userId,
    double saldo,
    int poin,
  ) async {
    final batch = _db.batch();
    batch.update(_db.collection('transaksi').doc(id), {'status': status});
    if (status == 'disetujui') {
      batch.update(_db.collection('users').doc(userId), {
        'saldo': FieldValue.increment(saldo),
        'poin': FieldValue.increment(poin),
      });
    }
    await batch.commit();
  }
}