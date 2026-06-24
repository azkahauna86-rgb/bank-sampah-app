import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'user/home_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder(
      stream: authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF2FA86B))),
          );
        }
        if (snapshot.hasData) {
          return FutureBuilder(
            future: authService.getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator(color: Color(0xFF2FA86B))),
                );
              }
              if (roleSnapshot.data == 'admin') {
                return const AdminDashboardScreen();
              }
              return const HomeScreen();
            },
          );
        }
        return const LoginScreen();
      },
    );
  }
}