import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sabidos2app/firebase_options.dart';
import 'package:sabidos2app/data/datasources/resumo_service.dart';
import 'package:sabidos2app/data/datasources/auth_service.dart';
import 'package:sabidos2app/data/core/checkauth.dart';
import 'package:sabidos2app/core/theme/theme_controller.dart';
import 'package:sabidos2app/core/theme/app_theme.dart';
import 'package:sabidos2app/core/theme/theme_storage.dart';
import 'package:sabidos2app/presentation/controllers/resumo_controller.dart';
import 'package:sabidos2app/presentation/controllers/authController.dart';
import 'package:sabidos2app/presentation/pages/login_page.dart';
import 'package:sabidos2app/presentation/pages/teste2.dart';
import 'package:sabidos2app/presentation/pages/perfil_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PEGADOR DE ERROS GLOBAL
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('--- ERRO FATAL FLUTTER ---');
    debugPrint(details.stack.toString());
  };

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final themeController = ThemeController(ThemeStorage());

  await themeController.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(AuthService())),

        ChangeNotifierProvider(
          create: (_) => ResumoController(ResumoService()),
        ),

        // 👇 USA A MESMA INSTÂNCIA
        ChangeNotifierProvider.value(value: themeController),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();

    return MaterialApp(
      title: 'Sabidos²',

      debugShowCheckedModeBanner: false,

      // 👇 ESSENCIAL
      themeMode: controller.themeMode,

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      home: const CheckAuth(),
    );
  }
}
