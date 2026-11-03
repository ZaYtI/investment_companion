import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/app_preferences.dart';
import 'providers/simulation_providers.dart';
import 'ui/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSeenWelcome = await AppPreferences.hasSeenWelcome();
  final router = createAppRouter(showWelcome: !hasSeenWelcome);
  final container = ProviderContainer();
  unawaited(_refreshPrices(container));
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: InvestmentCompanionApp(router: router),
    ),
  );
}

Future<void> _refreshPrices(ProviderContainer container) async {
  await container.read(priceRepositoryProvider).refreshFromApi();
  container.invalidate(priceSeriesProvider);
}
