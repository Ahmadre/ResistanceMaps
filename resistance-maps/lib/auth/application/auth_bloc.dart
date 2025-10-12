import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'auth_service.dart';
import 'oidc_client.dart';
import '../domain/session.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._auth, this._oidc) : super(const AuthState.unauthenticated()) {
    on<AppStarted>(_onStarted);
    on<SignInRequested>(_onSignIn);
    on<SignOutRequested>(_onSignOut);
    on<CompleteSignInFromRedirect>(_onCompleteFromRedirect);
  }

  final AuthService _auth;
  final OidcClientWrapper _oidc;

  void _onStarted(AppStarted event, Emitter<AuthState> emit) {
    final s = _auth.currentSession();
    if (s != null) {
      emit(AuthState.authenticated(s));
    }
  }

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final result = await _oidc.signIn();
      final session = Session(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        idToken: result.idToken,
        expiresAt: result.expiresAt,
        roles: result.roles,
      );
      await _auth.signInWithToken(
        session.accessToken,
        refreshToken: session.refreshToken,
        idToken: session.idToken,
        expiresAt: session.expiresAt,
        roles: session.roles,
      );
      emit(AuthState.authenticated(session));
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onCompleteFromRedirect(CompleteSignInFromRedirect event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final result = await _oidc.completeFromRedirect();
      if (result == null) {
        emit(const AuthState.unauthenticated());
        return;
      }
      final session = Session(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        idToken: result.idToken,
        expiresAt: result.expiresAt,
        roles: result.roles,
      );
      await _auth.signInWithToken(
        session.accessToken,
        refreshToken: session.refreshToken,
        idToken: session.idToken,
        expiresAt: session.expiresAt,
        roles: session.roles,
      );
      emit(AuthState.authenticated(session));
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }
}
