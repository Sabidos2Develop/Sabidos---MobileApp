import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/presentation/pages/login_page.dart';
import 'package:sabidos2app/presentation/pages/main_nav_page.dart';
import 'package:sabidos2app/presentation/controllers/authController.dart';

class CheckAuth extends StatelessWidget {
  const CheckAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isAuthenticated) {
          return const MainNavigationPage();
        } else {
          return const AuthPage();
        }
      },
    );
  }
}