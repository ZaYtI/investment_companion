import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/chapter_summary.dart';
import '../models/glossary_term.dart';
import '../models/lesson_page.dart';

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

Future<ChapterSummary> loadChapterSummary(int number) async {
  final chapters = await loadChapterSummaries();
  return chapters.firstWhere((chapter) => chapter.number == number);
}

Future<List<LessonPage>> loadLessonPages(int chapterNumber) async {
  final fileNumber = chapterNumber.toString().padLeft(2, '0');
  final text = await rootBundle.loadString(
    'assets/content/chapter_$fileNumber.json',
  );
  final json = jsonDecode(text) as Map<String, dynamic>;
  final levels = json['levels'] as List<dynamic>;
  final understandLevel = levels.first as Map<String, dynamic>;
  final screens = understandLevel['screens'] as List<dynamic>;
  return screens
      .map((screen) => LessonPage.fromJson(screen as Map<String, dynamic>))
      .toList();
}

Future<Map<String, GlossaryTerm>> loadGlossary() async {
  final text = await rootBundle.loadString('assets/content/glossary.json');
  final json = jsonDecode(text) as Map<String, dynamic>;
  final terms = (json['terms'] as List<dynamic>).map(
    (term) => GlossaryTerm.fromJson(term as Map<String, dynamic>),
  );
  return {for (final term in terms) term.id: term};
}
