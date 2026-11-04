import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_preferences.dart';
import '../services/daily_reminder.dart';

class AppSettings {
  final bool isBadgeAnimationEnabled;
  final bool isTimerEnabled;
  final bool isReminderEnabled;
  final bool hasAskedReminder;

  const AppSettings({
    this.isBadgeAnimationEnabled = true,
    this.isTimerEnabled = true,
    this.isReminderEnabled = false,
    this.hasAskedReminder = false,
  });

  AppSettings copyWith({
    bool? isBadgeAnimationEnabled,
    bool? isTimerEnabled,
    bool? isReminderEnabled,
    bool? hasAskedReminder,
  }) {
    return AppSettings(
      isBadgeAnimationEnabled:
          isBadgeAnimationEnabled ?? this.isBadgeAnimationEnabled,
      isTimerEnabled: isTimerEnabled ?? this.isTimerEnabled,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      hasAskedReminder: hasAskedReminder ?? this.hasAskedReminder,
    );
  }
}

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    return AppSettings(
      isBadgeAnimationEnabled: await AppPreferences.isBadgeAnimationEnabled(),
      isTimerEnabled: await AppPreferences.isTimerEnabled(),
      isReminderEnabled: await AppPreferences.isReminderEnabled(),
      hasAskedReminder: await AppPreferences.hasAskedReminder(),
    );
  }

  Future<void> setBadgeAnimationEnabled(bool isEnabled) async {
    await AppPreferences.setBadgeAnimationEnabled(isEnabled);
    state = AsyncData(
      (await future).copyWith(isBadgeAnimationEnabled: isEnabled),
    );
  }

  Future<void> setTimerEnabled(bool isEnabled) async {
    await AppPreferences.setTimerEnabled(isEnabled);
    state = AsyncData((await future).copyWith(isTimerEnabled: isEnabled));
  }

  Future<bool> enableReminder() async {
    final isGranted = await ref.read(dailyReminderProvider).requestPermission();
    await AppPreferences.setReminderAsked();
    await AppPreferences.setReminderEnabled(isGranted);
    state = AsyncData(
      (await future).copyWith(
        isReminderEnabled: isGranted,
        hasAskedReminder: true,
      ),
    );
    return isGranted;
  }

  Future<void> disableReminder() async {
    await AppPreferences.setReminderAsked();
    await AppPreferences.setReminderEnabled(false);
    state = AsyncData(
      (await future).copyWith(isReminderEnabled: false, hasAskedReminder: true),
    );
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
      AppSettingsNotifier.new,
    );

final dailyReminderProvider = Provider<DailyReminder>((ref) => DailyReminder());
