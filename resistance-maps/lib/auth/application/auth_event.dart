part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class SignInRequested extends AuthEvent {
  const SignInRequested();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Triggered on /callback route after the IdP redirects back to the app.
/// Completes the OAuth2/OIDC code flow on web and persists the session.
class CompleteSignInFromRedirect extends AuthEvent {
  const CompleteSignInFromRedirect();
}
