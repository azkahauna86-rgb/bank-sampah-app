import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;

  // Kirim pesan
  Future<void> kirimPesan({
    required String userId,
    required String text,
    required String senderId,
    required String senderRole,
    required String senderNama,
  }) async {
    await _db
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': senderId,
      'senderRole': senderRole,
      'senderNama': senderNama,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update metadata chat
    await _db.collection('chats').doc(userId).set({
      'userId': userId,
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'unreadAdmin': senderRole == 'user' ? FieldValue.increment(1) : 0,
    }, SetOptions(merge: true));
  }

  // Stream pesan per user
  Stream<QuerySnapshot> getPesan(String userId) {
    return _db
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Stream semua chat (untuk admin)
  Stream<QuerySnapshot> getAllChats() {
    return _db
        .collection('chats')
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  // Tandai pesan sudah dibaca
  Future<void> tandaiDibaca(String userId) async {
    await _db.collection('chats').doc(userId).update({'unreadAdmin': 0});
  }
}