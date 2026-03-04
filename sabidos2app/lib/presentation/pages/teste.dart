import 'package:flutter/material.dart';
import '../../data/datasources/auth_service.dart';
// import '../../data/datasources/token_storage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> logout(BuildContext context) async {
    await AuthService().logout();
    // await TokenStorage().clearToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
       child: const Text("Abrir CRUD"),
        ),
    );
  }
}