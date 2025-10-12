import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18next/i18next.dart';
import 'package:routemaster/routemaster.dart';
import '../app/router.dart';
import 'theme/app_theme.dart';
import '../auth/application/auth_bloc.dart';
import '../auth/application/auth_service.dart';
import '../auth/application/oidc_client.dart';
import '../auth/data/session_storage.dart';

class ResistanceMapsApp extends StatelessWidget {
  const ResistanceMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.dark();

    return BlocProvider(
      create: (_) =>
          AuthBloc(AuthService(SessionStorage()), OidcClientWrapper.fromEnv())
            ..add(const AppStarted()),
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
