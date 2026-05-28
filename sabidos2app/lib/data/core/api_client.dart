import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  late final Dio dio;

  //Abaixo tem o IP do emulador Android para acessar o backend local. Se for usar em dispositivo físico, mude para o IP da máquina onde o backend está rodando.
  //final String baseUrl = "http://10.0.2.2:5203/api";
  //final String baseUrl = "http://192.168.15.5:5203/api";
  final String baseUrl = "http://192.168.31.42:5203/api";

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              // Timeout de segurança para o Firebase não travar o app
              final token = await user.getIdToken().timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  debugPrint(
                    '--- TIMEOUT NO TOKEN (Firebase lento ou desconfigurado) ---',
                  );
                  return '';
                },
              );

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
          } catch (e) {
            debugPrint('--- ERRO NO INTERCEPTOR (TOKEN): $e ---');
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }
}

final apiClient = ApiClient().dio;
