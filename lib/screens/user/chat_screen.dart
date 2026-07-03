import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _msgC = TextEditingController();
  final _scrollC = ScrollController();
  bool _sending = false;

  Future<void> _kirim(String userId, String nama) async {
    final text = _msgC.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    _msgC.clear();
    await _chatService.kirimPesan(
      userId: userId,
      text: text,
      senderId: userId,
      senderRole: 'user',
      senderNama: nama,
    );
    setState(() => _sending = false);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollC.hasClients) {
        _scrollC.animateTo(
          _scrollC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Bank Sampah Digital', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1B7A4D),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 5, backgroundColor: Color(0xFF69F0AE)),
                SizedBox(width: 5),
                Text('Online', style: TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (ctx, userSnap) {
          if (!userSnap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF2FA86B)));
          final nama = userSnap.data!['nama'] ?? 'User';

          return Column(
            children: [
              // INFO BANNER
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFFE8F5E9),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF1B7A4D)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tanya seputar layanan bank sampah langsung ke admin kami.',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),

              // PESAN
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _chatService.getPesan(uid),
                  builder: (ctx, snap) {
                    if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF2FA86B)));
                    final docs = snap.data!.docs;
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('Belum ada pesan', style: TextStyle(color: Colors.grey.shade500)),
                            const SizedBox(height: 4),
                            Text('Mulai chat dengan admin di bawah', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                          ],
                        ),
                      );
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollC.hasClients) {
                        _scrollC.jumpTo(_scrollC.position.maxScrollExtent);
                      }
                    });

                    return ListView.builder(
                      controller: _scrollC,
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (ctx, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final isUser = data['senderRole'] == 'user';
                        final time = data['timestamp'] != null
                            ? DateFormat('HH:mm').format((data['timestamp'] as Timestamp).toDate())
                            : '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isUser) ...[
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF1B7A4D),
                                  child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    if (!isUser)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 3, left: 4),
                                        child: Text('Admin', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: isUser
                                            ? const LinearGradient(colors: [Color(0xFF2FA86B), Color(0xFF1B7A4D)])
                                            : null,
                                        color: isUser ? null : Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(16),
                                          topRight: const Radius.circular(16),
                                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                                          bottomRight: Radius.circular(isUser ? 4 : 16),
                                        ),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                                      ),
                                      child: Text(
                                        data['text'] ?? '',
                                        style: TextStyle(
                                          color: isUser ? Colors.white : const Color(0xFF1B3B2C),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                                      child: Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                    ),
                                  ],
                                ),
                              ),
                              if (isUser) ...[
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF2FA86B).withOpacity(0.15),
                                  child: Text(
                                    nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Color(0xFF1B7A4D), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
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

              // INPUT
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
                            hintText: 'Ketik pesan...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sending ? null : () => _kirim(uid, nama),
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
          );
        },
      ),
    );
  }
}