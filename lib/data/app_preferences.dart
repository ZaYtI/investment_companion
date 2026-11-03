import 'package:shared_preferences/shared_preferences.dart';

import '../models/investor_profile.dart';

class AppPreferences {
  static const _welcomeSeenKey = 'welcome_seen';
  static const _investorProfileKey = 'investor_profile';
  static const _badgeAnimationKey = 'badge_animation';
  static const _timerEnabledKey = 'timer_enabled';

  static Future<bool> hasSeenWelcome() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_welcomeSeenKey) ?? false;
  }

  static Future<void> saveWelcome(InvestorProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_investorProfileKey, profile.name);
    await preferences.setBool(_welcomeSeenKey, true);
  }

  static Future<bool> isBadgeAnimationEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_badgeAnimationKey) ?? true;
  }

  static Future<void> setBadgeAnimationEnabled(bool isEnabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_badgeAnimationKey, isEnabled);
  }

  static Future<bool> isTimerEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_timerEnabledKey) ?? true;
  }

  static Future<void> setTimerEnabled(bool isEnabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_timerEnabledKey, isEnabled);
  }
}
