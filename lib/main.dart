import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/app_preferences.dart';
import 'ui/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSeenWelcome = await AppPreferences.hasSeenWelcome();
  final router = createAppRouter(showWelcome: !hasSeenWelcome);
  runApp(ProviderScope(child: InvestmentCompanionApp(router: router)));
}
