import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'marker_model.dart';
import 'marker_repository.dart';

part 'marker_event.dart';
part 'marker_state.dart';

class MarkerBloc extends Bloc<MarkerEvent, MarkerState> {
  MarkerBloc(this.repo) : super(const MarkerState.initial()) {
    on<LoadPublicMarkers>(_onLoadPublic);
    on<SelectMarker>(_onSelect);
    on<ViewportChanged>(_onViewportChanged, transformer: _debounce(const Duration(milliseconds: 200)));
    on<LoadNextPage>(_onLoadNextPage);
    on<CreateMarker>(_onCreate);
    on<UpdateMarker>(_onUpdate);
    on<DeleteMarker>(_onDelete);
  }

  final MarkerRepository repo;
  CancelToken? _currentToken;

  Future<void> _onLoadPublic(LoadPublicMarkers event, Emitter<MarkerState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final markers = await repo.fetchPublic();
      emit(state.copyWith(loading: false, markers: markers));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadNextPage(LoadNextPage event, Emitter<MarkerState> emit) async {
    if (!state.hasMore || state.paging || state.viewportKey.isEmpty) return;
    await _loadViewport(page: state.page + 1, emit: emit, append: true);
  }

  Future<void> _onViewportChanged(ViewportChanged event, Emitter<MarkerState> emit) async {
    final key =
        '${event.south.toStringAsFixed(3)}:${event.west.toStringAsFixed(3)}:${event.north.toStringAsFixed(3)}:${event.east.toStringAsFixed(3)}:${event.zoom.toStringAsFixed(1)}';
    if (key == state.viewportKey && (state.loading || state.paging)) return;
    emit(state.copyWith(viewportKey: key, page: 0));
    await _loadViewport(page: 0, emit: emit, append: false, bounds: [event.south, event.west, event.north, event.east]);
  }

  Future<void> _loadViewport({
    required int page,
    required Emitter<MarkerState> emit,
    required bool append,
    List<double>? bounds,
  }) async {
    final south = bounds != null ? bounds[0] : null;
    final west = bounds != null ? bounds[1] : null;
    final north = bounds != null ? bounds[2] : null;
    final east = bounds != null ? bounds[3] : null;

    _currentToken?.cancel('new-request');
    final token = CancelToken();
    _currentToken = token;

    emit(state.copyWith(paging: page > 0, loading: page == 0));
    try {
      final res = await repo.fetchViewport(
        south: south ?? 0,
        west: west ?? 0,
        north: north ?? 0,
        east: east ?? 0,
        page: page,
        cancelToken: token,
      );
      final items = append ? [...state.markers, ...res.items] : res.items;
      emit(state.copyWith(loading: false, paging: false, markers: items, page: res.page, hasMore: res.hasMore));
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) return; // ignore cancelled
      emit(state.copyWith(loading: false, paging: false, error: e.toString()));
    }
  }

  Future<void> _onCreate(CreateMarker event, Emitter<MarkerState> emit) async {
    try {
      final created = await repo.createMarker(
        title: event.title,
        lat: event.lat,
        lng: event.lng,
        description: event.description,
        tags: event.tags,
        visibility: event.visibility,
      );
      emit(state.copyWith(markers: [created, ...state.markers]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateMarker event, Emitter<MarkerState> emit) async {
    try {
      final updated = await repo.updateMarker(
        event.id,
        title: event.title,
        lat: event.lat,
        lng: event.lng,
        description: event.description,
        tags: event.tags,
        visibility: event.visibility,
      );
      final newList = state.markers.map((m) => m.id == updated.id ? updated : m).toList();
      emit(state.copyWith(markers: newList));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteMarker event, Emitter<MarkerState> emit) async {
    try {
      await repo.deleteMarker(event.id);
      final newList = state.markers.where((m) => m.id != event.id).toList();
      emit(
        state.copyWith(
          markers: newList,
          selectedMarkerId: state.selectedMarkerId == event.id ? null : state.selectedMarkerId,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}

extension _MarkerBlocPriv on MarkerBloc {
  void _onSelect(SelectMarker event, Emitter<MarkerState> emit) {
    emit(state.copyWith(selectedMarkerId: event.markerId));
  }

  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }
}
