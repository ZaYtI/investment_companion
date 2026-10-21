import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const contentDir = 'assets/content';
const levelTypes = ['understand', 'simulate', 'challenge'];
const screenKinds = ['hook', 'explanation', 'example', 'quiz'];

Map<String, dynamic> _read(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

List<Map<String, dynamic>> _list(Object? value) =>
    (value as List).cast<Map<String, dynamic>>();

List<File> _chapterFiles() =>
    Directory(contentDir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('chapter_'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

void _expectValidQuestion(Map<String, dynamic> question, String prefix) {
  expect(question['id'], startsWith(prefix));
  final choices = question['choices'] as List;
  expect(choices.length, greaterThanOrEqualTo(2));
  expect(question['answerIndex'], inInclusiveRange(0, choices.length - 1));
  expect(question['explanation'], isNotEmpty);
}

void main() {
  final glossaryIds = {
    for (final term in _list(_read('$contentDir/glossary.json')['terms']))
      term['id'] as String,
  };

  test('le glossaire n\'a pas de doublon', () {
    final terms = _list(_read('$contentDir/glossary.json')['terms']);
    expect(glossaryIds, hasLength(terms.length));
  });

  for (final file in _chapterFiles()) {
    group(file.path, () {
      final chapter = _read(file.path);
      final chapterId = chapter['id'] as String;
      final levels = _list(chapter['levels']);

      test('a un identifiant cohérent avec son numéro', () {
        expect(chapterId, 'ch${chapter['number']}');
      });

      test('a trois niveaux dans l\'ordre', () {
        expect(levels.map((l) => l['type']), levelTypes);
        for (final (index, level) in levels.indexed) {
          expect(level['id'], '$chapterId.l${index + 1}');
        }
      });

      test('cite des séries qui existent', () {
        for (final id in (chapter['series'] as List).cast<String>()) {
          expect(
            File('assets/data/series/$id.json').existsSync(),
            isTrue,
            reason: id,
          );
        }
      });

      test('a des écrans et des quiz valides', () {
        final understand = levels.first;
        for (final screen in _list(understand['screens'])) {
          expect(screen['id'], startsWith('${understand['id']}.s'));
          expect(screenKinds, contains(screen['kind']));
          for (final term in (screen['terms'] as List).cast<String>()) {
            expect(glossaryIds, contains(term));
          }
          if (screen['kind'] == 'quiz') {
            final questions = _list(screen['questions']);
            expect(
              screen['passingScore'],
              inInclusiveRange(1, questions.length),
            );
            for (final question in questions) {
              _expectValidQuestion(question, '${understand['id']}.q');
            }
          }
        }
      });

      test('a une question de lecture valide', () {
        final simulate = levels[1];
        _expectValidQuestion(
          simulate['readingQuestion'] as Map<String, dynamic>,
          '${simulate['id']}.q',
        );
      });

      test('a un défi avec une situation et un message clé', () {
        final challenge = levels[2]['challenge'] as Map<String, dynamic>;
        expect(challenge['kind'], isNotEmpty);
        expect(challenge['situation'], isNotEmpty);
        expect(challenge['keyMessage'], isNotEmpty);
      });
    });
  }
}
