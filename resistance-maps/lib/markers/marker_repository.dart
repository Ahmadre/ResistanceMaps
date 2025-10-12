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
}
