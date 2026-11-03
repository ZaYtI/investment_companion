import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress.dart';

class ProgressRepository {
  static const _progressKey = 'progress';

  Future<Progress> load() async {
    final preferences = await SharedPreferences.getInstance();
    final text = preferences.getString(_progressKey);
    if (text == null) return const Progress();
    return Progress.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_progressKey);
  }

  Future<void> save(Progress progress) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_progressKey, jsonEncode(progress.toJson()));
  }
}
