import 'package:dio/dio.dart';
import '../core/api_client.dart';
import 'connection_model.dart';

class ConnectionRepository {
  ConnectionRepository(this.api);
  final ApiClient api;

  Future<ConnectionModel> invite(String usernameOrEmail) async {
    final Response res = await api.dio.post('/api/connections', data: {'usernameOrEmail': usernameOrEmail});
    return ConnectionModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ConnectionModel>> getPending() async {
    final Response res = await api.dio.get('/api/connections/pending');
    final data = res.data as List<dynamic>;
    return data.map((e) => ConnectionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ConnectionModel>> getSent() async {
    final Response res = await api.dio.get('/api/connections/sent');
    final data = res.data as List<dynamic>;
    return data.map((e) => ConnectionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ConnectionModel>> getAccepted() async {
    final Response res = await api.dio.get('/api/connections');
    final data = res.data as List<dynamic>;
    return data.map((e) => ConnectionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ConnectionModel> accept(String id) async {
    final Response res = await api.dio.post('/api/connections/$id/accept');
    return ConnectionModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ConnectionModel> reject(String id) async {
    final Response res = await api.dio.post('/api/connections/$id/reject');
    return ConnectionModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> remove(String id) async {
    await api.dio.delete('/api/connections/$id');
  }
}
