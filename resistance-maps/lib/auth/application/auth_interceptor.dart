import 'dart:async';
import 'package:dio/dio.dart';
import '../data/session_storage.dart';
import 'oidc_client.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._oidc);

  final SessionStorage _storage;
  final OidcClientWrapper _oidc;

  bool _isRefreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final session = _storage.load();
    final token = session?.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final res = err.response;
    if (res?.statusCode == 401) {
      final refreshed = await _handleTokenRefresh();
      if (refreshed) {
        try {
          final req = await _retry(err.requestOptions);
          return handler.resolve(req);
        } catch (e) {
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final dio = Dio();
    final session = _storage.load();
    if (session != null && session.accessToken.isNotEmpty) {
      requestOptions.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    return dio.fetch(requestOptions);
  }

  Future<bool> _handleTokenRefresh() async {
    final session = _storage.load();
    final refresh = session?.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;

    if (_isRefreshing) {
      final waiter = Completer<void>();
      _refreshWaiters.add(waiter);
      await waiter.future;
      final s = _storage.load();
      return s != null && s.accessToken.isNotEmpty;
    }

    _isRefreshing = true;
    try {
      final res = await _oidc.refresh(refresh);
      if (res == null) return false;
      // Save updated session
      await _storage.saveCurrentWith(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken ?? refresh,
        idToken: res.idToken,
        expiresAt: res.expiresAt,
        roles: res.roles,
      );
      return true;
    } finally {
      _isRefreshing = false;
      for (final c in _refreshWaiters) {
        if (!c.isCompleted) c.complete();
      }
      _refreshWaiters.clear();
    }
  }
}
