import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_challenge.dart';

final dailyChallengeContentProvider = FutureProvider<DailyChallengeContent>((
  ref,
) async {
  final text = await rootBundle.loadString(
    'assets/content/daily_challenges.json',
  );
  return DailyChallengeContent.fromJson(
    jsonDecode(text) as Map<String, dynamic>,
  );
});
