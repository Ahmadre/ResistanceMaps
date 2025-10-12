import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:routemaster/routemaster.dart';
import 'app/app.dart';
import 'auth/data/session_storage.dart';

// Env values are provided via --dart-define; see core/env.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Register adapters before opening boxes
  await SessionStorage().init();
  // Open app box with a fallback for legacy/unknown typeIds on web
  try {
    await Hive.openBox('app');
  } catch (e) {
    final msg = e.toString();
    if (e is HiveError || msg.contains('unknown typeId')) {
      // One-time recovery: clear corrupted/legacy data and reopen
      await Hive.deleteBoxFromDisk('app');
      await Hive.openBox('app');
    } else {
      rethrow;
    }
  }

  // Use path URL strategy for Flutter Web
  Routemaster.setPathUrlStrategy();

  runApp(const ResistanceMapsApp());
}

// main.dart intentionally contains only bootstrap code
