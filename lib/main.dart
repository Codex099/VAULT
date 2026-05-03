import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/progress_model.dart';
import 'providers/movie_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/progress_provider.dart';
import 'services/hive_service.dart';
import 'services/tmdb_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── System UI ─────────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ─── Hive initialization ───────────────────────────────────────────────────
  await Hive.initFlutter();

  // Register TypeAdapters
  Hive.registerAdapter(WatchProgressAdapter());
  Hive.registerAdapter(FavoriteItemAdapter());
  Hive.registerAdapter(HistoryItemAdapter());
  Hive.registerAdapter(SeriesProgressAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  // Open boxes & init services
  await HiveService.init();
  await TmdbService.init();

  runApp(const CineStreamApp());
}

class CineStreamApp extends StatelessWidget {
  const CineStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp.router(
        title: 'VΛULT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: appRouter,
        // Support French (default) + Arabic
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('ar', 'SA'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('fr', 'FR'),
        builder: (context, child) {
          // Apply text scaling clamp for accessibility without breaking layout
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
