import 'package:dio/dio.dart';
import '../core/api_client.dart';
import 'file_metadata_model.dart';

class FileRepository {
  FileRepository(this.api);
  final ApiClient api;

  Future<FileMetadataModel> upload(List<int> bytes, String fileName, String contentType) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName, contentType: DioMediaType.parse(contentType)),
    });
    final Response res = await api.dio.post('/api/files/upload', data: formData);
    return FileMetadataModel.fromJson(res.data as Map<String, dynamic>);
  }

  String downloadUrl(String id) => '${api.dio.options.baseUrl}/api/files/$id';

  Future<FileMetadataModel?> getMetadata(String id) async {
    try {
      final Response res = await api.dio.get('/api/files/$id/meta');
      return FileMetadataModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> deleteFile(String id) async {
    await api.dio.delete('/api/files/$id');
  }
}
