import 'package:dio/dio.dart';
import 'env.dart';

class ApiClient {
  ApiClient({List<Interceptor>? interceptors}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBase,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
