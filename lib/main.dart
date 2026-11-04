import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/app_preferences.dart';
import 'providers/settings_provider.dart';
import 'providers/simulation_providers.dart';
import 'services/daily_reminder.dart';
import 'ui/router/app_router.dart';
import 'ui/router/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSeenWelcome = await AppPreferences.hasSeenWelcome();
  final router = createAppRouter(showWelcome: !hasSeenWelcome);
  final reminder = DailyReminder();
  await reminder.initialize(
    onOpened: () => router.go(AppRoutes.dailyChallenge),
  );
  if (await reminder.wasAppOpenedByReminder()) {
    router.go(AppRoutes.dailyChallenge);
  }
  final container = ProviderContainer(
    retry: _neverRetry,
    overrides: [dailyReminderProvider.overrideWithValue(reminder)],
  );
  unawaited(_refreshPrices(container));
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: InvestmentCompanionApp(router: router),
    ),
  );
}

Duration? _neverRetry(int retryCount, Object error) => null;

Future<void> _refreshPrices(ProviderContainer container) async {
  await container.read(priceRepositoryProvider).refreshFromApi();
  container.invalidate(priceSeriesProvider);
}
