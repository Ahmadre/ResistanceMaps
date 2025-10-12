part of 'marker_bloc.dart';

abstract class MarkerEvent extends Equatable {
  const MarkerEvent();
  @override
  List<Object?> get props => [];
}

class LoadPublicMarkers extends MarkerEvent {
  const LoadPublicMarkers();
}

class SelectMarker extends MarkerEvent {
  const SelectMarker(this.markerId);
  final String? markerId;

  @override
  List<Object?> get props => [markerId];
}

class ViewportChanged extends MarkerEvent {
  const ViewportChanged({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
    required this.zoom,
  });
  final double south;
  final double west;
  final double north;
  final double east;
  final double zoom;

  @override
  List<Object?> get props => [south, west, north, east, zoom];
}

class LoadNextPage extends MarkerEvent {
  const LoadNextPage();
}

class CreateMarker extends MarkerEvent {
  const CreateMarker({
    required this.title,
    required this.lat,
    required this.lng,
    this.description,
    this.tags,
    this.visibility,
  });
  final String title;
  final double lat;
  final double lng;
  final String? description;
  final List<String>? tags;
  final String? visibility;

  @override
  List<Object?> get props => [title, lat, lng, description, tags, visibility];
}

class UpdateMarker extends MarkerEvent {
  const UpdateMarker(this.id, {this.title, this.lat, this.lng, this.description, this.tags, this.visibility});
  final String id;
  final String? title;
  final double? lat;
  final double? lng;
  final String? description;
  final List<String>? tags;
  final String? visibility;

  @override
  List<Object?> get props => [id, title, lat, lng, description, tags, visibility];
}

class DeleteMarker extends MarkerEvent {
  const DeleteMarker(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
