import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'map_list_model.dart';
import 'map_list_repository.dart';

// --- Events ---
abstract class MapListEvent extends Equatable {
  const MapListEvent();
  @override
  List<Object?> get props => [];
}

class LoadPublicLists extends MapListEvent {
  const LoadPublicLists();
}

class LoadAccessibleLists extends MapListEvent {
  const LoadAccessibleLists();
}

class CreateMapList extends MapListEvent {
  const CreateMapList({required this.title, this.description, this.visibility, this.groupId, this.markerIds, this.routeIds});
  final String title;
  final String? description;
  final String? visibility;
  final String? groupId;
  final List<String>? markerIds;
  final List<String>? routeIds;
  @override
  List<Object?> get props => [title, description, visibility, groupId, markerIds, routeIds];
}

class UpdateMapList extends MapListEvent {
  const UpdateMapList(this.id, {this.title, this.description, this.markerIds, this.routeIds});
  final String id;
  final String? title;
  final String? description;
  final List<String>? markerIds;
  final List<String>? routeIds;
  @override
  List<Object?> get props => [id, title, description, markerIds, routeIds];
}

class DeleteMapList extends MapListEvent {
  const DeleteMapList(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class SelectMapList extends MapListEvent {
  const SelectMapList(this.listId);
  final String? listId;
  @override
  List<Object?> get props => [listId];
}

// --- State ---
class MapListState extends Equatable {
  final List<MapListModel> lists;
  final String? selectedListId;
  final bool loading;
  final String? error;

  const MapListState({this.lists = const [], this.selectedListId, this.loading = false, this.error});

  MapListModel? get selectedList {
    if (selectedListId == null) return null;
    try {
      return lists.firstWhere((l) => l.id == selectedListId);
    } catch (_) {
      return null;
    }
  }

  MapListState copyWith({List<MapListModel>? lists, String? selectedListId, bool clearSelection = false, bool? loading, String? error}) {
    return MapListState(
      lists: lists ?? this.lists,
      selectedListId: clearSelection ? null : (selectedListId ?? this.selectedListId),
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [lists, selectedListId, loading, error];
}

// --- Bloc ---
class MapListBloc extends Bloc<MapListEvent, MapListState> {
  MapListBloc(this.repo) : super(const MapListState()) {
    on<LoadPublicLists>(_onLoadPublic);
    on<LoadAccessibleLists>(_onLoadAccessible);
    on<CreateMapList>(_onCreate);
    on<UpdateMapList>(_onUpdate);
    on<DeleteMapList>(_onDelete);
    on<SelectMapList>(_onSelect);
  }

  final MapListRepository repo;

  Future<void> _onLoadPublic(LoadPublicLists event, Emitter<MapListState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final lists = await repo.fetchPublic();
      emit(state.copyWith(loading: false, lists: lists));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadAccessible(LoadAccessibleLists event, Emitter<MapListState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final lists = await repo.fetchAccessible();
      emit(state.copyWith(loading: false, lists: lists));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onCreate(CreateMapList event, Emitter<MapListState> emit) async {
    try {
      final list = await repo.createList(
        title: event.title,
        description: event.description,
        visibility: event.visibility,
        groupId: event.groupId,
        markerIds: event.markerIds,
        routeIds: event.routeIds,
      );
      emit(state.copyWith(lists: [list, ...state.lists]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateMapList event, Emitter<MapListState> emit) async {
    try {
      final list = await repo.updateList(
        event.id,
        title: event.title,
        description: event.description,
        markerIds: event.markerIds,
        routeIds: event.routeIds,
      );
      final newLists = state.lists.map((l) => l.id == list.id ? list : l).toList();
      emit(state.copyWith(lists: newLists));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteMapList event, Emitter<MapListState> emit) async {
    try {
      await repo.deleteList(event.id);
      final newLists = state.lists.where((l) => l.id != event.id).toList();
      emit(state.copyWith(lists: newLists, clearSelection: state.selectedListId == event.id));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onSelect(SelectMapList event, Emitter<MapListState> emit) {
    emit(state.copyWith(selectedListId: event.listId, clearSelection: event.listId == null));
  }
}
