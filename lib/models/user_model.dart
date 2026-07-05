class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String role; // 'user' atau 'admin'
  final double saldo;
  final int poin;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    this.saldo = 0,
    this.poin = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      saldo: (map['saldo'] ?? 0).toDouble(),
      poin: (map['poin'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'email': email,
      'role': role,
      'saldo': saldo,
      'poin': poin,
    };
  }
}