import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'connection_model.dart';
import 'connection_repository.dart';

// --- Events ---
abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();
  @override
  List<Object?> get props => [];
}

class LoadConnections extends ConnectionEvent {
  const LoadConnections();
}

class SendInvitation extends ConnectionEvent {
  const SendInvitation(this.usernameOrEmail);
  final String usernameOrEmail;
  @override
  List<Object?> get props => [usernameOrEmail];
}

class AcceptInvitation extends ConnectionEvent {
  const AcceptInvitation(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class RejectInvitation extends ConnectionEvent {
  const RejectInvitation(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class RemoveConnection extends ConnectionEvent {
  const RemoveConnection(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

// --- State ---
class ConnectionBlocState extends Equatable {
  final List<ConnectionModel> accepted;
  final List<ConnectionModel> pending;
  final List<ConnectionModel> sent;
  final bool loading;
  final String? error;

  const ConnectionBlocState({
    this.accepted = const [],
    this.pending = const [],
    this.sent = const [],
    this.loading = false,
    this.error,
  });

  ConnectionBlocState copyWith({
    List<ConnectionModel>? accepted,
    List<ConnectionModel>? pending,
    List<ConnectionModel>? sent,
    bool? loading,
    String? error,
  }) {
    return ConnectionBlocState(
      accepted: accepted ?? this.accepted,
      pending: pending ?? this.pending,
      sent: sent ?? this.sent,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [accepted, pending, sent, loading, error];
}

// --- Bloc ---
class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionBlocState> {
  ConnectionBloc(this.repo) : super(const ConnectionBlocState()) {
    on<LoadConnections>(_onLoad);
    on<SendInvitation>(_onSend);
    on<AcceptInvitation>(_onAccept);
    on<RejectInvitation>(_onReject);
    on<RemoveConnection>(_onRemove);
  }

  final ConnectionRepository repo;

  Future<void> _onLoad(LoadConnections event, Emitter<ConnectionBlocState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final accepted = await repo.getAccepted();
      final pending = await repo.getPending();
      final sent = await repo.getSent();
      emit(state.copyWith(loading: false, accepted: accepted, pending: pending, sent: sent));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onSend(SendInvitation event, Emitter<ConnectionBlocState> emit) async {
    try {
      final conn = await repo.invite(event.usernameOrEmail);
      emit(state.copyWith(sent: [...state.sent, conn]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAccept(AcceptInvitation event, Emitter<ConnectionBlocState> emit) async {
    try {
      final conn = await repo.accept(event.id);
      emit(state.copyWith(
        pending: state.pending.where((c) => c.id != event.id).toList(),
        accepted: [...state.accepted, conn],
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onReject(RejectInvitation event, Emitter<ConnectionBlocState> emit) async {
    try {
      await repo.reject(event.id);
      emit(state.copyWith(pending: state.pending.where((c) => c.id != event.id).toList()));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRemove(RemoveConnection event, Emitter<ConnectionBlocState> emit) async {
    try {
      await repo.remove(event.id);
      emit(state.copyWith(
        accepted: state.accepted.where((c) => c.id != event.id).toList(),
        sent: state.sent.where((c) => c.id != event.id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
