import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/catalog_read_source.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/firestore_catalog_repository.dart';
import 'data/repositories/quotes_repository.dart';
import 'features/auth/login_screen.dart';
import 'features/shell/home_shell.dart';
import 'state/auth_controller.dart';
import 'state/cart_controller.dart';
import 'state/catalog_controller.dart';
import 'state/quotes_controller.dart';

/// Raiz de la aplicacion: registra el estado compartido y decide que pantalla
/// mostrar segun la sesion.
class RepuestosProApp extends StatelessWidget {
  const RepuestosProApp({
    super.key,
    this.catalogRepository,
    this.catalogReadSource,
  });

  /// Drift local: quotes + import. En pruebas se inyecta en memoria.
  final CatalogRepository? catalogRepository;

  /// Fuente de lectura del catalogo. Por defecto: Firestore.
  final CatalogReadSource? catalogReadSource;

  @override
  Widget build(BuildContext context) {
    final CatalogRepository localRepo =
        catalogRepository ?? CatalogRepository();
    // UI del catalogo: siempre Firestore (mismo modelo Product).
    // Drift (localRepo) solo para quotes / import / restore.
    final CatalogReadSource remoteSource =
        catalogReadSource ?? FirestoreCatalogRepository();

    // ignore: avoid_print
    print(
      '[FIRESTORE_MODE] app wiring source=${remoteSource.runtimeType} '
      'importStore=${localRepo.runtimeType}',
    );

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(const AuthRepository()),
        ),
        ChangeNotifierProvider<CatalogController>(
          create: (_) => CatalogController(
            remoteSource,
            importStore: localRepo,
          )..load(),
        ),
        ChangeNotifierProvider<CartController>(create: (_) => CartController()),
        ChangeNotifierProvider<QuotesController>(
          create: (_) => QuotesController(
            QuotesRepository(database: localRepo.db),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'REPUESTOS PRO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        locale: const Locale('es'),
        supportedLocales: const <Locale>[Locale('es'), Locale('en')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const _AuthGate(),
      ),
    );
  }
}

/// Muestra el login o el catalogo segun el estado de la sesion.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final bool signedIn = context.select<AuthController, bool>(
      (AuthController auth) => auth.isSignedIn,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: signedIn
          ? const HomeShell(key: ValueKey<String>('shell'))
          : const LoginScreen(key: ValueKey<String>('login')),
    );
  }
}
