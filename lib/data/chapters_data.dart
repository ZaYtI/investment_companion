import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/chapter_summary.dart';

Future<List<ChapterSummary>> loadChapterSummaries() async {
  final text = await rootBundle.loadString(
    'assets/content/chapters_index.json',
  );
  final json = jsonDecode(text) as Map<String, dynamic>;
  final chapters = json['chapters'] as List<dynamic>;
  return chapters
      .map(
        (chapter) => ChapterSummary.fromJson(chapter as Map<String, dynamic>),
      )
      .toList();
}
