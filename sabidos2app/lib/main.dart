import 'package:flutter/material.dart';
import 'package:sabidos2app/data/datasources/resumo_service.dart';
import 'package:sabidos2app/data/core/checkauth.dart';
import 'package:sabidos2app/presentation/controllers/resumo_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/presentation/controllers/authController.dart';
import '../../data/datasources/auth_service.dart';
import 'package:sabidos2app/presentation/pages/main_nav_page.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabidos²',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // useMaterial3: true
      ),
      home: MainNavigationPage(),
    );
  }
}

// class LoginPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//       ),
//       body: Center(
//         child: Text('Login Page'),
//       ),
//     );
//   }
// }
