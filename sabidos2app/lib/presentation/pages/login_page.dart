import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'widgets/cadastrotab.dart';
import 'widgets/logintab.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF1E1B2E),
        body: SafeArea(
  child: Column(
    children: [
      const SizedBox(height: 32),

      SvgPicture.asset(
        'assets/images/logo.svg',
        width: 150,
        height: 150,
      ),

      const SizedBox(height: 24),

      Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF292535),
            borderRadius: BorderRadius.circular(50),
          ),
          child: TabBar(
            indicator: BoxDecoration(
              color: const Color(0xFFFBCB4E),
              borderRadius: BorderRadius.circular(50),
              
            ),
            splashBorderRadius: BorderRadius.circular(50),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white,
            dividerColor: Colors.transparent,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            tabs: const [
              Tab(text: "Login", height: 45),
              Tab(text: "Cadastro", height: 45),
            ],
          ),
        ),
      ),

      const SizedBox(height: 32),

      const Expanded(
        child: TabBarView(
          children: [
            LoginTab(),
            CadastroTab(),
          ],
        ),
      ),
    ],
  ),
),
      ),
    );
  }
}