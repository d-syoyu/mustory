import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../auth/auth_controller.dart';

class AuthInterceptor extends Interceptor {
  final String? Function() getAccessToken;

  AuthInterceptor(this.getAccessToken);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

final dioProvider = Provider<Dio>(
  (ref) {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['MUSTORY_API_BASE_URL'] ?? 'http://localhost:8000',
        // Reduced timeouts for better UX
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    // Add auth interceptor
    dio.interceptors.add(
      AuthInterceptor(() => ref.read(accessTokenProvider)),
    );

    // Only add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    return dio;
  },
);
