import 'package:dio/dio.dart';
import '../core/api_client.dart';
import 'marker_model.dart';

class PageResult<T> {
  final List<T> items;
  final bool hasMore;
  final int page;
  final int size;
  PageResult({required this.items, required this.hasMore, required this.page, required this.size});
}

class MarkerRepository {
  MarkerRepository(this.api);
  final ApiClient api;

  Future<List<MarkerModel>> fetchPublic() async {
    final Response res = await api.dio.get('/api/markers/public');
    final data = res.data as List<dynamic>;
    return data.map((e) => MarkerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MarkerModel>> fetchAccessible() async {
    final Response res = await api.dio.get('/api/markers/me');
    final data = res.data as List<dynamic>;
    return data.map((e) => MarkerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PageResult<MarkerModel>> fetchViewport({
    required double south,
    required double west,
    required double north,
    required double east,
    int page = 0,
    int size = 100,
    CancelToken? cancelToken,
  }) async {
    final Response res = await api.dio.get(
      '/api/markers/public/viewport',
      queryParameters: {'south': south, 'west': west, 'north': north, 'east': east, 'page': page, 'size': size},
      cancelToken: cancelToken,
    );
    final data = res.data as Map<String, dynamic>;
    final content = (data['content'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    final items = content.map(MarkerModel.fromJson).toList();
    final bool last = data['last'] as bool? ?? (items.length < size);
    final int number = (data['number'] as num?)?.toInt() ?? page;
    final int pageSize = (data['size'] as num?)?.toInt() ?? size;
    return PageResult(items: items, hasMore: !last, page: number, size: pageSize);
  }

  Future<MarkerModel?> getById(String id) async {
    try {
      final Response res = await api.dio.get('/api/markers/$id');
      return MarkerModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<MarkerModel?> getByShareToken(String token) async {
    try {
      final Response res = await api.dio.get('/api/markers/shared/$token');
      return MarkerModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<MarkerModel> createMarker({
    required String title,
    required double lat,
    required double lng,
    String? description,
    List<String>? tags,
    String? visibility,
    String? groupId,
    String? webLink,
    String? expiresAt,
    String? password,
    String? coverImageId,
    List<String>? imageIds,
    List<String>? documentIds,
  }) async {
    final Response res = await api.dio.post(
      '/api/markers',
      data: {
        'title': title,
        'lat': lat,
        'lng': lng,
        if (description != null) 'description': description,
        if (tags != null) 'tags': tags,
        if (visibility != null) 'visibility': visibility,
        if (groupId != null) 'groupId': groupId,
        if (webLink != null) 'webLink': webLink,
        if (expiresAt != null) 'expiresAt': expiresAt,
        if (password != null) 'password': password,
        if (coverImageId != null) 'coverImageId': coverImageId,
        if (imageIds != null) 'imageIds': imageIds,
        if (documentIds != null) 'documentIds': documentIds,
      },
    );
    return MarkerModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MarkerModel> updateMarker(
    String id, {
    String? title,
    double? lat,
    double? lng,
    String? description,
    List<String>? tags,
    String? visibility,
    String? webLink,
    String? expiresAt,
    String? password,
    String? coverImageId,
    List<String>? imageIds,
    List<String>? documentIds,
  }) async {
    final Map<String, dynamic> body = {};
    if (title != null) body['title'] = title;
    if (lat != null) body['lat'] = lat;
    if (lng != null) body['lng'] = lng;
    if (description != null) body['description'] = description;
    if (tags != null) body['tags'] = tags;
    if (visibility != null) body['visibility'] = visibility;
    if (webLink != null) body['webLink'] = webLink;
    if (expiresAt != null) body['expiresAt'] = expiresAt;
    if (password != null) body['password'] = password;
    if (coverImageId != null) body['coverImageId'] = coverImageId;
    if (imageIds != null) body['imageIds'] = imageIds;
    if (documentIds != null) body['documentIds'] = documentIds;
    final Response res = await api.dio.put('/api/markers/$id', data: body);
    return MarkerModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteMarker(String id) async {
    await api.dio.delete('/api/markers/$id');
  }

  Future<MarkerModel> generateShareToken(String id, {bool isPublic = false}) async {
    final Response res = await api.dio.post('/api/markers/$id/share-token', queryParameters: {'isPublic': isPublic});
    return MarkerModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MarkerModel> revokeShareToken(String id, {bool isPublic = false}) async {
    final Response res = await api.dio.delete('/api/markers/$id/share-token', queryParameters: {'isPublic': isPublic});
    return MarkerModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<bool> verifyPassword(String id, String password) async {
    final Response res = await api.dio.post('/api/markers/$id/verify-password', data: {'password': password});
    return (res.data as Map<String, dynamic>)['valid'] == true;
  }
}
