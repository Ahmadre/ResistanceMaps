import 'package:freezed_annotation/freezed_annotation.dart';

part 'marker_model.freezed.dart';

@freezed
class MarkerModel with _$MarkerModel {
  const factory MarkerModel({
    required String id,
    required String title,
    required double lat,
    required double lng,
    String? iconUrl,
  }) = _MarkerModel;

  factory MarkerModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['_id'] ?? '').toString();
    final title = (json['title'] ?? '').toString();
    final latRaw = json['lat'];
    final lngRaw = json['lng'];
    final lat = latRaw is num
        ? latRaw.toDouble()
        : double.parse(latRaw.toString());
    final lng = lngRaw is num
        ? lngRaw.toDouble()
        : double.parse(lngRaw.toString());
    final iconUrl = (json['iconUrl'] ?? json['icon_url']) as String?;
    return MarkerModel(
      id: id,
      title: title,
      lat: lat,
      lng: lng,
      iconUrl: iconUrl,
    );
  }
}
