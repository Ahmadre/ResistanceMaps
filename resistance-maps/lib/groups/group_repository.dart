import 'package:dio/dio.dart';
import '../core/api_client.dart';
import 'group_model.dart';

class GroupRepository {
  GroupRepository(this.api);
  final ApiClient api;

  Future<GroupModel> create({required String name, String? description}) async {
    final Response res = await api.dio.post('/api/groups', data: {
      'name': name,
      if (description != null) 'description': description,
    });
    return GroupModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<GroupModel>> myGroups() async {
    final Response res = await api.dio.get('/api/groups/me');
    final data = res.data as List<dynamic>;
    return data.map((e) => GroupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<GroupModel>> search(String query, {int page = 0, int size = 20}) async {
    final Response res = await api.dio.get('/api/groups/search', queryParameters: {'q': query, 'page': page, 'size': size});
    final data = res.data as Map<String, dynamic>;
    final content = (data['content'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    return content.map(GroupModel.fromJson).toList();
  }

  Future<GroupModel?> getById(String id) async {
    try {
      final Response res = await api.dio.get('/api/groups/$id');
      return GroupModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<GroupModel> update(String id, {String? name, String? description}) async {
    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    final Response res = await api.dio.patch('/api/groups/$id', data: body);
    return GroupModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await api.dio.delete('/api/groups/$id');
  }

  Future<List<GroupMemberModel>> getMembers(String groupId) async {
    final Response res = await api.dio.get('/api/groups/$groupId/members');
    final data = res.data as List<dynamic>;
    return data.map((e) => GroupMemberModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GroupMemberModel> addMember(String groupId, String userId) async {
    final Response res = await api.dio.post('/api/groups/$groupId/members', data: {'userId': userId});
    return GroupMemberModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> removeMember(String groupId, String userId) async {
    await api.dio.delete('/api/groups/$groupId/members/$userId');
  }

  Future<GroupMemberModel> promoteMember(String groupId, String userId) async {
    final Response res = await api.dio.post('/api/groups/$groupId/members/$userId/promote');
    return GroupMemberModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<GroupMemberModel> demoteMember(String groupId, String userId) async {
    final Response res = await api.dio.post('/api/groups/$groupId/members/$userId/demote');
    return GroupMemberModel.fromJson(res.data as Map<String, dynamic>);
  }
}
