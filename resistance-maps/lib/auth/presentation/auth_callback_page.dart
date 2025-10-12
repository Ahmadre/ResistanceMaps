import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import '../application/auth_bloc.dart';
import 'callback_post.dart';
import 'callback_flow.dart';

class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  bool _fired = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fired) {
      _fired = true;
      // On web, try to send the current URL to the opener (replaces auth.html bridging)
      postCallbackUrlIfPossible();
      // If this is a popup flow, the parent will handle token exchange,
      // so don't attempt to complete here to avoid double handling.
      isPopupFlow().then((isPopup) {
        if (!isPopup) {
          context.read<AuthBloc>().add(const CompleteSignInFromRedirect());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.isLoading != curr.isLoading || prev.session != curr.session,
          listener: (context, state) {
            if (!state.isLoading) {
              Routemaster.of(context).replace('/');
            }
          },
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
