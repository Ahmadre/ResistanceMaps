part of 'marker_bloc.dart';

class MarkerState extends Equatable {
  final bool loading;
  final List<MarkerModel> markers;
  final String? error;
  final String? selectedMarkerId;
  final bool paging;
  final bool hasMore;
  final int page;
  final String viewportKey; // hashed bounds

  const MarkerState({
    required this.loading,
    required this.markers,
    this.error,
    this.selectedMarkerId,
    required this.paging,
    required this.hasMore,
    required this.page,
    required this.viewportKey,
  });

  const MarkerState.initial()
    : loading = false,
      markers = const [],
      error = null,
      selectedMarkerId = null,
      paging = false,
      hasMore = false,
      page = 0,
      viewportKey = '';

  MarkerState copyWith({
    bool? loading,
    List<MarkerModel>? markers,
    String? error,
    String? selectedMarkerId,
    bool? paging,
    bool? hasMore,
    int? page,
    String? viewportKey,
  }) => MarkerState(
    loading: loading ?? this.loading,
    markers: markers ?? this.markers,
    error: error,
    selectedMarkerId: selectedMarkerId ?? this.selectedMarkerId,
    paging: paging ?? this.paging,
    hasMore: hasMore ?? this.hasMore,
    page: page ?? this.page,
    viewportKey: viewportKey ?? this.viewportKey,
  );

  MarkerModel? get selected {
    if (selectedMarkerId == null) return null;
    try {
      return markers.firstWhere((m) => m.id == selectedMarkerId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
    loading,
    markers,
    error,
    selectedMarkerId,
    paging,
    hasMore,
    page,
    viewportKey,
  ];
}
