import 'package:shared_preferences/shared_preferences.dart';

import '../models/investor_profile.dart';

class AppPreferences {
  static const _welcomeSeenKey = 'welcome_seen';
  static const _investorProfileKey = 'investor_profile';

  static Future<bool> hasSeenWelcome() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_welcomeSeenKey) ?? false;
  }

  static Future<void> saveWelcome(InvestorProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_investorProfileKey, profile.name);
    await preferences.setBool(_welcomeSeenKey, true);
  }
}
