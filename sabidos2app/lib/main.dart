import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:sabidos2app/firebase_options.dart';
import 'package:sabidos2app/data/datasources/resumo_service.dart';
import 'package:sabidos2app/data/datasources/auth_service.dart';
import 'package:sabidos2app/data/core/checkauth.dart';
import 'package:sabidos2app/presentation/controllers/resumo_controller.dart';
import 'package:sabidos2app/presentation/controllers/authController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(AuthService())),
        ChangeNotifierProvider(
          create: (_) => ResumoController(ResumoService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabidos²',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CheckAuth(),
    );
  }
}