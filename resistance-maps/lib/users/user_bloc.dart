import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'user_profile_model.dart';
import 'user_repository.dart';

// --- Events ---
abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class LoadCurrentUser extends UserEvent {
  const LoadCurrentUser();
}

class UpdateProfile extends UserEvent {
  const UpdateProfile({this.isPublic, this.displayName});
  final bool? isPublic;
  final String? displayName;
  @override
  List<Object?> get props => [isPublic, displayName];
}

class SearchUsers extends UserEvent {
  const SearchUsers(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

// --- State ---
class UserState extends Equatable {
  final UserProfileModel? currentUser;
  final List<UserProfileModel> searchResults;
  final bool loading;
  final String? error;

  const UserState({this.currentUser, this.searchResults = const [], this.loading = false, this.error});

  UserState copyWith({UserProfileModel? currentUser, List<UserProfileModel>? searchResults, bool? loading, String? error}) {
    return UserState(
      currentUser: currentUser ?? this.currentUser,
      searchResults: searchResults ?? this.searchResults,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [currentUser, searchResults, loading, error];
}

// --- Bloc ---
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this.repo) : super(const UserState()) {
    on<LoadCurrentUser>(_onLoad);
    on<UpdateProfile>(_onUpdate);
    on<SearchUsers>(_onSearch);
  }

  final UserRepository repo;

  Future<void> _onLoad(LoadCurrentUser event, Emitter<UserState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final user = await repo.getMe();
      emit(state.copyWith(loading: false, currentUser: user));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateProfile event, Emitter<UserState> emit) async {
    try {
      final user = await repo.updateMe(isPublic: event.isPublic, displayName: event.displayName);
      emit(state.copyWith(currentUser: user));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSearch(SearchUsers event, Emitter<UserState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final results = await repo.search(event.query);
      emit(state.copyWith(loading: false, searchResults: results));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
