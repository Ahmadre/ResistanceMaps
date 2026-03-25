import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'route_model.dart';
import 'route_repository.dart';

// --- Events ---
abstract class RouteEvent extends Equatable {
  const RouteEvent();
  @override
  List<Object?> get props => [];
}

class LoadPublicRoutes extends RouteEvent {
  const LoadPublicRoutes();
}

class LoadAccessibleRoutes extends RouteEvent {
  const LoadAccessibleRoutes();
}

class SelectRoute extends RouteEvent {
  const SelectRoute(this.routeId);
  final String? routeId;
  @override
  List<Object?> get props => [routeId];
}

class CreateRoute extends RouteEvent {
  const CreateRoute({
    required this.title,
    this.description,
    this.waypoints,
    this.visibility,
    this.groupId,
    this.tags,
    this.webLink,
    this.password,
  });
  final String title;
  final String? description;
  final List<GeoPoint>? waypoints;
  final String? visibility;
  final String? groupId;
  final List<String>? tags;
  final String? webLink;
  final String? password;
  @override
  List<Object?> get props => [title];
}

class UpdateRoute extends RouteEvent {
  const UpdateRoute(this.id, {this.title, this.description, this.waypoints, this.visibility, this.tags});
  final String id;
  final String? title;
  final String? description;
  final List<GeoPoint>? waypoints;
  final String? visibility;
  final List<String>? tags;
  @override
  List<Object?> get props => [id];
}

class DeleteRoute extends RouteEvent {
  const DeleteRoute(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

// --- State ---
class RouteState extends Equatable {
  final List<RouteModel> routes;
  final String? selectedRouteId;
  final bool loading;
  final String? error;

  const RouteState({this.routes = const [], this.selectedRouteId, this.loading = false, this.error});

  RouteModel? get selectedRoute {
    if (selectedRouteId == null) return null;
    try {
      return routes.firstWhere((r) => r.id == selectedRouteId);
    } catch (_) {
      return null;
    }
  }

  RouteState copyWith({List<RouteModel>? routes, String? selectedRouteId, bool clearSelection = false, bool? loading, String? error}) {
    return RouteState(
      routes: routes ?? this.routes,
      selectedRouteId: clearSelection ? null : (selectedRouteId ?? this.selectedRouteId),
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [routes, selectedRouteId, loading, error];
}

// --- Bloc ---
class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc(this.repo) : super(const RouteState()) {
    on<LoadPublicRoutes>(_onLoadPublic);
    on<LoadAccessibleRoutes>(_onLoadAccessible);
    on<SelectRoute>(_onSelect);
    on<CreateRoute>(_onCreate);
    on<UpdateRoute>(_onUpdate);
    on<DeleteRoute>(_onDelete);
  }

  final RouteRepository repo;

  Future<void> _onLoadPublic(LoadPublicRoutes event, Emitter<RouteState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final routes = await repo.fetchPublic();
      emit(state.copyWith(loading: false, routes: routes));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadAccessible(LoadAccessibleRoutes event, Emitter<RouteState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final routes = await repo.fetchAccessible();
      emit(state.copyWith(loading: false, routes: routes));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onSelect(SelectRoute event, Emitter<RouteState> emit) {
    emit(state.copyWith(selectedRouteId: event.routeId, clearSelection: event.routeId == null));
  }

  Future<void> _onCreate(CreateRoute event, Emitter<RouteState> emit) async {
    try {
      final route = await repo.createRoute(
        title: event.title,
        description: event.description,
        waypoints: event.waypoints,
        visibility: event.visibility,
        groupId: event.groupId,
        tags: event.tags,
        webLink: event.webLink,
        password: event.password,
      );
      emit(state.copyWith(routes: [route, ...state.routes]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateRoute event, Emitter<RouteState> emit) async {
    try {
      final route = await repo.updateRoute(
        event.id,
        title: event.title,
        description: event.description,
        waypoints: event.waypoints,
        visibility: event.visibility,
        tags: event.tags,
      );
      final newList = state.routes.map((r) => r.id == route.id ? route : r).toList();
      emit(state.copyWith(routes: newList));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteRoute event, Emitter<RouteState> emit) async {
    try {
      await repo.deleteRoute(event.id);
      final newList = state.routes.where((r) => r.id != event.id).toList();
      emit(state.copyWith(routes: newList, clearSelection: state.selectedRouteId == event.id));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
