part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final Session? session;
  final String? error;

  const AuthState({required this.isLoading, this.session, this.error});

  const AuthState.unauthenticated()
    : isLoading = false,
      session = null,
      error = null;
  const AuthState.loading() : isLoading = true, session = null, error = null;
  const AuthState.failure(this.error) : isLoading = false, session = null;
  const AuthState.authenticated(this.session) : isLoading = false, error = null;

  @override
  List<Object?> get props => [isLoading, session, error];
}
