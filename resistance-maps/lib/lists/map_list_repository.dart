import 'package:dio/dio.dart';
import '../core/api_client.dart';
import 'map_list_model.dart';

class MapListRepository {
  MapListRepository(this.api);
  final ApiClient api;

  Future<List<MapListModel>> fetchPublic() async {
    final Response res = await api.dio.get('/api/lists/public');
    final data = res.data as List<dynamic>;
    return data.map((e) => MapListModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MapListModel>> fetchAccessible() async {
    final Response res = await api.dio.get('/api/lists/me');
    final data = res.data as List<dynamic>;
    return data.map((e) => MapListModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MapListModel?> getById(String id) async {
    try {
      final Response res = await api.dio.get('/api/lists/$id');
      return MapListModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<MapListModel?> getByShareToken(String token) async {
    try {
      final Response res = await api.dio.get('/api/lists/shared/$token');
      return MapListModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<MapListModel> createList({
    required String title,
    String? description,
    String? visibility,
    String? groupId,
    List<String>? markerIds,
    List<String>? routeIds,
    String? expiresAt,
    String? password,
  }) async {
    final Response res = await api.dio.post('/api/lists', data: {
      'title': title,
      if (description != null) 'description': description,
      if (visibility != null) 'visibility': visibility,
      if (groupId != null) 'groupId': groupId,
      if (markerIds != null) 'markerIds': markerIds,
      if (routeIds != null) 'routeIds': routeIds,
      if (expiresAt != null) 'expiresAt': expiresAt,
      if (password != null) 'password': password,
    });
    return MapListModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MapListModel> updateList(
    String id, {
    String? title,
    String? description,
    String? visibility,
    List<String>? markerIds,
    List<String>? routeIds,
    String? expiresAt,
    String? password,
  }) async {
    final Map<String, dynamic> body = {};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (visibility != null) body['visibility'] = visibility;
    if (markerIds != null) body['markerIds'] = markerIds;
    if (routeIds != null) body['routeIds'] = routeIds;
    if (expiresAt != null) body['expiresAt'] = expiresAt;
    if (password != null) body['password'] = password;
    final Response res = await api.dio.put('/api/lists/$id', data: body);
    return MapListModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteList(String id) async {
    await api.dio.delete('/api/lists/$id');
  }

  Future<MapListModel> generateShareToken(String id, {bool isPublic = false}) async {
    final Response res = await api.dio.post('/api/lists/$id/share-token', queryParameters: {'isPublic': isPublic});
    return MapListModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MapListModel> revokeShareToken(String id, {bool isPublic = false}) async {
    final Response res = await api.dio.delete('/api/lists/$id/share-token', queryParameters: {'isPublic': isPublic});
    return MapListModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<bool> verifyPassword(String id, String password) async {
    final Response res = await api.dio.post('/api/lists/$id/verify-password', data: {'password': password});
    return (res.data as Map<String, dynamic>)['valid'] == true;
  }
}
