import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_preferences.dart';

class AppSettings {
  final bool isBadgeAnimationEnabled;
  final bool isTimerEnabled;

  const AppSettings({
    this.isBadgeAnimationEnabled = true,
    this.isTimerEnabled = true,
  });
}

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    return AppSettings(
      isBadgeAnimationEnabled: await AppPreferences.isBadgeAnimationEnabled(),
      isTimerEnabled: await AppPreferences.isTimerEnabled(),
    );
  }

  Future<void> setBadgeAnimationEnabled(bool isEnabled) async {
    await AppPreferences.setBadgeAnimationEnabled(isEnabled);
    final current = await future;
    state = AsyncData(
      AppSettings(
        isBadgeAnimationEnabled: isEnabled,
        isTimerEnabled: current.isTimerEnabled,
      ),
    );
  }

  Future<void> setTimerEnabled(bool isEnabled) async {
    await AppPreferences.setTimerEnabled(isEnabled);
    final current = await future;
    state = AsyncData(
      AppSettings(
        isBadgeAnimationEnabled: current.isBadgeAnimationEnabled,
        isTimerEnabled: isEnabled,
      ),
    );
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
      AppSettingsNotifier.new,
    );
