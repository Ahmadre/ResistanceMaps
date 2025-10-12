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
