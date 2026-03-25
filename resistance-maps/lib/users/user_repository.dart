import 'package:dio/dio.dart';
import '../core/api_client.dart';
import 'user_profile_model.dart';

class UserRepository {
  UserRepository(this.api);
  final ApiClient api;

  Future<UserProfileModel> getMe() async {
    final Response res = await api.dio.get('/api/users/me');
    return UserProfileModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserProfileModel> updateMe({bool? isPublic, String? displayName}) async {
    final Map<String, dynamic> body = {};
    if (isPublic != null) body['isPublic'] = isPublic;
    if (displayName != null) body['displayName'] = displayName;
    final Response res = await api.dio.patch('/api/users/me', data: body);
    return UserProfileModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<UserProfileModel>> search(String query, {int page = 0, int size = 20}) async {
    final Response res = await api.dio.get('/api/users/search', queryParameters: {'q': query, 'page': page, 'size': size});
    final data = res.data as Map<String, dynamic>;
    final content = (data['content'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    return content.map(UserProfileModel.fromJson).toList();
  }

  Future<UserProfileModel?> getByUserId(String userId) async {
    try {
      final Response res = await api.dio.get('/api/users/$userId');
      return UserProfileModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) return null;
      rethrow;
    }
  }
}
