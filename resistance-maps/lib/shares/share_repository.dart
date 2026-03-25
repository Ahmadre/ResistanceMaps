import 'package:dio/dio.dart';
import '../core/api_client.dart';
import 'share_model.dart';

class ShareRepository {
  ShareRepository(this.api);
  final ApiClient api;

  Future<ShareModel> shareWithUser({
    required ResourceType resourceType,
    required String resourceId,
    required String userId,
    String? expiresAt,
  }) async {
    final Response res = await api.dio.post('/api/shares', data: {
      'resourceType': resourceTypeToString(resourceType),
      'resourceId': resourceId,
      'sharedWithUserId': userId,
      if (expiresAt != null) 'expiresAt': expiresAt,
    });
    return ShareModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ShareModel> shareWithGroup({
    required ResourceType resourceType,
    required String resourceId,
    required String groupId,
    String? expiresAt,
  }) async {
    final Response res = await api.dio.post('/api/shares', data: {
      'resourceType': resourceTypeToString(resourceType),
      'resourceId': resourceId,
      'sharedWithGroupId': groupId,
      if (expiresAt != null) 'expiresAt': expiresAt,
    });
    return ShareModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ShareModel>> getSharesForResource(ResourceType resourceType, String resourceId) async {
    final Response res = await api.dio.get('/api/shares', queryParameters: {
      'resourceType': resourceTypeToString(resourceType),
      'resourceId': resourceId,
    });
    final data = res.data as List<dynamic>;
    return data.map((e) => ShareModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> removeShare(String id) async {
    await api.dio.delete('/api/shares/$id');
  }
}
