import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/chat_service.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      appBar: AppBar(
        title: const Text('Pesan Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B7A4D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getAllChats(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF2FA86B)));
          if (snap.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Belum ada pesan masuk', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.docs.length,
            itemBuilder: (ctx, i) {
              final data = snap.data!.docs[i].data() as Map<String, dynamic>;
              final userId = data['userId'] ?? '';
              final lastMsg = data['lastMessage'] ?? '';
              final unread = data['unreadAdmin'] ?? 0;
              final lastTime = data['lastTimestamp'] != null
                  ? DateFormat('HH:mm').format((data['lastTimestamp'] as Timestamp).toDate())
                  : '';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (ctx, userSnap) {
                  final nama = userSnap.hasData ? (userSnap.data!['nama'] ?? 'User') : 'Loading...';
                  final email = userSnap.hasData ? (userSnap.data!['email'] ?? '') : '';

                  return GestureDetector(
                    onTap: () {
                      chatService.tandaiDibaca(userId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminChatRoomScreen(userId: userId, userNama: nama),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF2FA86B).withOpacity(0.15),
                                child: Text(
                                  nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Color(0xFF1B7A4D), fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                              if (unread > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(email, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                const SizedBox(height: 4),
                                Text(
                                  lastMsg,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: unread > 0 ? const Color(0xFF1B3B2C) : Colors.grey.shade500, fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(lastTime, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                              const SizedBox(height: 4),
                              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AdminChatRoomScreen extends StatefulWidget {
  final String userId;
  final String userNama;
  const AdminChatRoomScreen({super.key, required this.userId, required this.userNama});
  @override
  State<AdminChatRoomScreen> createState() => _AdminChatRoomScreenState();
}

class _AdminChatRoomScreenState extends State<AdminChatRoomScreen> {
  final _chatService = ChatService();
  final _msgC = TextEditingController();
  final _scrollC = ScrollController();
  bool _sending = false;

  Future<void> _kirim() async {
    final text = _msgC.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    _msgC.clear();
    await _chatService.kirimPesan(
      userId: widget.userId,
      text: text,
      senderId: 'admin',
      senderRole: 'admin',
      senderNama: 'Admin',
    );
    setState(() => _sending = false);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollC.hasClients) {
        _scrollC.animateTo(_scrollC.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('User', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1B7A4D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getPesan(widget.userId),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF2FA86B)));
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(child: Text('Belum ada pesan', style: TextStyle(color: Colors.grey.shade500)));
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollC.hasClients) _scrollC.jumpTo(_scrollC.position.maxScrollExtent);
                });
                return ListView.builder(
                  controller: _scrollC,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final isAdmin = data['senderRole'] == 'admin';
                    final time = data['timestamp'] != null
                        ? DateFormat('HH:mm').format((data['timestamp'] as Timestamp).toDate())
                        : '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isAdmin) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF2FA86B).withOpacity(0.15),
                              child: Text(widget.userNama[0].toUpperCase(), style: const TextStyle(color: Color(0xFF1B7A4D), fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: isAdmin ? const LinearGradient(colors: [Color(0xFF2FA86B), Color(0xFF1B7A4D)]) : null,
                                    color: isAdmin ? null : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                                      bottomRight: Radius.circular(isAdmin ? 4 : 16),
                                    ),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                                  ),
                                  child: Text(data['text'] ?? '', style: TextStyle(color: isAdmin ? Colors.white : const Color(0xFF1B3B2C), fontSize: 14)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                                  child: Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                ),
                              ],
                            ),
                          ),
                          if (isAdmin) ...[
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFF1B7A4D),
                              child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 16),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4FBF6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _msgC,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Balas pesan...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sending ? null : _kirim,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2FA86B), Color(0xFF1B7A4D)]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFF2FA86B).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: _sending
                        ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}