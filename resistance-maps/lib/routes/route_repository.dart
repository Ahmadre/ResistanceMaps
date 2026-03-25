import 'package:dio/dio.dart';
import '../core/api_client.dart';
import 'route_model.dart';

class RouteRepository {
  RouteRepository(this.api);
  final ApiClient api;

  Future<List<RouteModel>> fetchPublic() async {
    final Response res = await api.dio.get('/api/routes/public');
    final data = res.data as List<dynamic>;
    return data.map((e) => RouteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<RouteModel>> fetchAccessible() async {
    final Response res = await api.dio.get('/api/routes/me');
    final data = res.data as List<dynamic>;
    return data.map((e) => RouteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RouteModel?> getById(String id) async {
    try {
      final Response res = await api.dio.get('/api/routes/$id');
      return RouteModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<RouteModel?> getByShareToken(String token) async {
    try {
      final Response res = await api.dio.get('/api/routes/shared/$token');
      return RouteModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<RouteModel> createRoute({
    required String title,
    String? description,
    List<GeoPoint>? waypoints,
    String? visibility,
    String? groupId,
    List<String>? tags,
    String? webLink,
    String? expiresAt,
    String? password,
  }) async {
    final Response res = await api.dio.post('/api/routes', data: {
      'title': title,
      if (description != null) 'description': description,
      if (waypoints != null) 'waypoints': waypoints.map((w) => w.toJson()).toList(),
      if (visibility != null) 'visibility': visibility,
      if (groupId != null) 'groupId': groupId,
      if (tags != null) 'tags': tags,
      if (webLink != null) 'webLink': webLink,
      if (expiresAt != null) 'expiresAt': expiresAt,
      if (password != null) 'password': password,
    });
    return RouteModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<RouteModel> updateRoute(
    String id, {
    String? title,
    String? description,
    List<GeoPoint>? waypoints,
    String? visibility,
    List<String>? tags,
    String? webLink,
    String? expiresAt,
    String? password,
  }) async {
    final Map<String, dynamic> body = {};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (waypoints != null) body['waypoints'] = waypoints.map((w) => w.toJson()).toList();
    if (visibility != null) body['visibility'] = visibility;
    if (tags != null) body['tags'] = tags;
    if (webLink != null) body['webLink'] = webLink;
    if (expiresAt != null) body['expiresAt'] = expiresAt;
    if (password != null) body['password'] = password;
    final Response res = await api.dio.put('/api/routes/$id', data: body);
    return RouteModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteRoute(String id) async {
    await api.dio.delete('/api/routes/$id');
  }

  Future<RouteModel> generateShareToken(String id, {bool isPublic = false}) async {
    final Response res = await api.dio.post('/api/routes/$id/share-token', queryParameters: {'isPublic': isPublic});
    return RouteModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<RouteModel> revokeShareToken(String id, {bool isPublic = false}) async {
    final Response res = await api.dio.delete('/api/routes/$id/share-token', queryParameters: {'isPublic': isPublic});
    return RouteModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<bool> verifyPassword(String id, String password) async {
    final Response res = await api.dio.post('/api/routes/$id/verify-password', data: {'password': password});
    return (res.data as Map<String, dynamic>)['valid'] == true;
  }
}
