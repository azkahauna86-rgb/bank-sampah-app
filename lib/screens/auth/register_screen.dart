import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _register() async {
    if (_namaC.text.isEmpty || _emailC.text.isEmpty || _passC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi!')),
      );
      return;
    }
    if (_passC.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final err = await auth.register(_namaC.text.trim(), _emailC.text.trim(), _passC.text.trim());
    if (mounted) {
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: Colors.red.shade400),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Akun berhasil dibuat!'), backgroundColor: Color(0xFF2FA86B)),
        );
        Navigator.pop(context);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F4C3A),
              Color(0xFF1B7A4D),
              Color(0xFF2FA86B),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              left: -50,
              child: _blobCircle(200, Colors.white.withOpacity(0.07)),
            ),
            Positioned(
              bottom: -70,
              right: -50,
              child: _blobCircle(200, Colors.white.withOpacity(0.06)),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.person_add_alt_1_rounded, size: 44, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Buat Akun Baru',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Yuk mulai kelola sampahmu',
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
                          ),
                          const SizedBox(height: 28),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                ),
                                child: Column(
                                  children: [
                                    _GlassTextField(
                                      controller: _namaC,
                                      hint: 'Nama Lengkap',
                                      icon: Icons.person_outline_rounded,
                                    ),
                                    const SizedBox(height: 14),
                                    _GlassTextField(
                                      controller: _emailC,
                                      hint: 'Email',
                                      icon: Icons.email_outlined,
                                    ),
                                    const SizedBox(height: 14),
                                    _GlassTextField(
                                      controller: _passC,
                                      hint: 'Password (min. 6 karakter)',
                                      icon: Icons.lock_outline_rounded,
                                      obscure: _obscure,
                                      suffix: IconButton(
                                        icon: Icon(
                                          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() => _obscure = !_obscure),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _loading ? null : _register,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(0xFF0F4C3A),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Color(0xFF0F4C3A),
                                                ),
                                              )
                                            : const Text(
                                                'Daftar',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blobCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _GlassTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}