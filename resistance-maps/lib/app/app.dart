import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18next/i18next.dart';
import 'package:routemaster/routemaster.dart';
import '../app/router.dart';
import 'theme/app_theme.dart';
import '../auth/application/auth_bloc.dart';
import '../auth/application/auth_service.dart';
import '../auth/application/auth_interceptor.dart';
import '../auth/application/oidc_client.dart';
import '../auth/data/session_storage.dart';
import '../core/api_client.dart';
import '../markers/marker_bloc.dart';
import '../markers/marker_repository.dart';
import '../routes/route_bloc.dart';
import '../routes/route_repository.dart';
import '../groups/group_bloc.dart';
import '../groups/group_repository.dart';
import '../connections/connection_bloc.dart';
import '../connections/connection_repository.dart';
import '../lists/map_list_bloc.dart';
import '../lists/map_list_repository.dart';
import '../users/user_bloc.dart';
import '../users/user_repository.dart';

class ResistanceMapsApp extends StatefulWidget {
  const ResistanceMapsApp({super.key});

  @override
  State<ResistanceMapsApp> createState() => _ResistanceMapsAppState();
}

class _ResistanceMapsAppState extends State<ResistanceMapsApp> {
  late final SessionStorage _sessionStorage;
  late final OidcClientWrapper _oidc;
  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _sessionStorage = SessionStorage();
    _oidc = OidcClientWrapper.fromEnv();
    _apiClient = ApiClient(interceptors: [AuthInterceptor(_sessionStorage, _oidc)]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.dark();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(AuthService(_sessionStorage), _oidc)..add(const AppStarted()),
        ),
        BlocProvider(create: (_) => MarkerBloc(MarkerRepository(_apiClient))),
        BlocProvider(create: (_) => RouteBloc(RouteRepository(_apiClient))),
        BlocProvider(create: (_) => GroupBloc(GroupRepository(_apiClient))),
        BlocProvider(create: (_) => ConnectionBloc(ConnectionRepository(_apiClient))),
        BlocProvider(create: (_) => MapListBloc(MapListRepository(_apiClient))),
        BlocProvider(create: (_) => UserBloc(UserRepository(_apiClient))),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (ctx) => I18Next.of(ctx)!.t('app.title'),
        theme: theme,
        localizationsDelegates: [
          ...GlobalMaterialLocalizations.delegates,
          I18NextLocalizationDelegate(
            locales: appLocales,
            dataSource: AssetBundleLocalizationDataSource(
              bundlePath: 'assets/i18n',
            ),
          ),
        ],
        supportedLocales: appLocales,
        routerDelegate: RoutemasterDelegate(routesBuilder: (_) => appRoutes),
        routeInformationParser: const RoutemasterParser(),
      ),
    );
  }
}

const appLocales = [Locale('de', 'DE'), Locale('en', 'GB')];
