import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'group_model.dart';
import 'group_repository.dart';

// --- Events ---
abstract class GroupEvent extends Equatable {
  const GroupEvent();
  @override
  List<Object?> get props => [];
}

class LoadMyGroups extends GroupEvent {
  const LoadMyGroups();
}

class CreateGroup extends GroupEvent {
  const CreateGroup({required this.name, this.description});
  final String name;
  final String? description;
  @override
  List<Object?> get props => [name, description];
}

class UpdateGroup extends GroupEvent {
  const UpdateGroup(this.id, {this.name, this.description});
  final String id;
  final String? name;
  final String? description;
  @override
  List<Object?> get props => [id, name, description];
}

class DeleteGroup extends GroupEvent {
  const DeleteGroup(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class LoadGroupMembers extends GroupEvent {
  const LoadGroupMembers(this.groupId);
  final String groupId;
  @override
  List<Object?> get props => [groupId];
}

class AddGroupMember extends GroupEvent {
  const AddGroupMember(this.groupId, this.userId);
  final String groupId;
  final String userId;
  @override
  List<Object?> get props => [groupId, userId];
}

class RemoveGroupMember extends GroupEvent {
  const RemoveGroupMember(this.groupId, this.userId);
  final String groupId;
  final String userId;
  @override
  List<Object?> get props => [groupId, userId];
}

class PromoteGroupMember extends GroupEvent {
  const PromoteGroupMember(this.groupId, this.userId);
  final String groupId;
  final String userId;
  @override
  List<Object?> get props => [groupId, userId];
}

class DemoteGroupMember extends GroupEvent {
  const DemoteGroupMember(this.groupId, this.userId);
  final String groupId;
  final String userId;
  @override
  List<Object?> get props => [groupId, userId];
}

class SelectGroup extends GroupEvent {
  const SelectGroup(this.groupId);
  final String? groupId;
  @override
  List<Object?> get props => [groupId];
}

// --- State ---
class GroupState extends Equatable {
  final List<GroupModel> groups;
  final List<GroupMemberModel> members;
  final String? selectedGroupId;
  final bool loading;
  final String? error;

  const GroupState({
    this.groups = const [],
    this.members = const [],
    this.selectedGroupId,
    this.loading = false,
    this.error,
  });

  GroupModel? get selectedGroup {
    if (selectedGroupId == null) return null;
    try {
      return groups.firstWhere((g) => g.id == selectedGroupId);
    } catch (_) {
      return null;
    }
  }

  GroupState copyWith({
    List<GroupModel>? groups,
    List<GroupMemberModel>? members,
    String? selectedGroupId,
    bool clearSelectedGroup = false,
    bool? loading,
    String? error,
  }) {
    return GroupState(
      groups: groups ?? this.groups,
      members: members ?? this.members,
      selectedGroupId: clearSelectedGroup ? null : (selectedGroupId ?? this.selectedGroupId),
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [groups, members, selectedGroupId, loading, error];
}

// --- Bloc ---
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc(this.repo) : super(const GroupState()) {
    on<LoadMyGroups>(_onLoadMyGroups);
    on<CreateGroup>(_onCreateGroup);
    on<UpdateGroup>(_onUpdateGroup);
    on<DeleteGroup>(_onDeleteGroup);
    on<LoadGroupMembers>(_onLoadMembers);
    on<AddGroupMember>(_onAddMember);
    on<RemoveGroupMember>(_onRemoveMember);
    on<PromoteGroupMember>(_onPromote);
    on<DemoteGroupMember>(_onDemote);
    on<SelectGroup>(_onSelect);
  }

  final GroupRepository repo;

  Future<void> _onLoadMyGroups(LoadMyGroups event, Emitter<GroupState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final groups = await repo.myGroups();
      emit(state.copyWith(loading: false, groups: groups));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateGroup(CreateGroup event, Emitter<GroupState> emit) async {
    try {
      final group = await repo.create(name: event.name, description: event.description);
      emit(state.copyWith(groups: [group, ...state.groups]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateGroup(UpdateGroup event, Emitter<GroupState> emit) async {
    try {
      final group = await repo.update(event.id, name: event.name, description: event.description);
      final newList = state.groups.map((g) => g.id == group.id ? group : g).toList();
      emit(state.copyWith(groups: newList));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteGroup(DeleteGroup event, Emitter<GroupState> emit) async {
    try {
      await repo.delete(event.id);
      final newList = state.groups.where((g) => g.id != event.id).toList();
      emit(state.copyWith(groups: newList, clearSelectedGroup: state.selectedGroupId == event.id));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLoadMembers(LoadGroupMembers event, Emitter<GroupState> emit) async {
    try {
      final members = await repo.getMembers(event.groupId);
      emit(state.copyWith(members: members));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddMember(AddGroupMember event, Emitter<GroupState> emit) async {
    try {
      final member = await repo.addMember(event.groupId, event.userId);
      emit(state.copyWith(members: [...state.members, member]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRemoveMember(RemoveGroupMember event, Emitter<GroupState> emit) async {
    try {
      await repo.removeMember(event.groupId, event.userId);
      final newList = state.members.where((m) => m.userId != event.userId).toList();
      emit(state.copyWith(members: newList));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onPromote(PromoteGroupMember event, Emitter<GroupState> emit) async {
    try {
      final member = await repo.promoteMember(event.groupId, event.userId);
      final newList = state.members.map((m) => m.userId == member.userId ? member : m).toList();
      emit(state.copyWith(members: newList));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDemote(DemoteGroupMember event, Emitter<GroupState> emit) async {
    try {
      final member = await repo.demoteMember(event.groupId, event.userId);
      final newList = state.members.map((m) => m.userId == member.userId ? member : m).toList();
      emit(state.copyWith(members: newList));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onSelect(SelectGroup event, Emitter<GroupState> emit) {
    emit(state.copyWith(selectedGroupId: event.groupId, clearSelectedGroup: event.groupId == null));
  }
}
