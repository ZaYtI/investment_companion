import 'quiz_question.dart';

enum LessonPageKind { hook, explanation, example, quiz }

class ExampleStep {
  final String label;
  final String value;

  const ExampleStep({required this.label, required this.value});

  factory ExampleStep.fromJson(Map<String, dynamic> json) {
    return ExampleStep(
      label: json['label'] as String,
      value: json['value'] as String,
    );
  }
}

class LessonPage {
  final LessonPageKind kind;
  final String title;
  final String text;
  final String? pip;
  final List<String> terms;
  final List<String> options;
  final List<ExampleStep> steps;
  final List<QuizQuestion> questions;
  final int passingScore;

  const LessonPage({
    required this.kind,
    required this.title,
    required this.text,
    required this.pip,
    required this.terms,
    required this.options,
    required this.steps,
    required this.questions,
    required this.passingScore,
  });

  factory LessonPage.fromJson(Map<String, dynamic> json) {
    final steps = json['steps'] as List<dynamic>? ?? [];
    final questions = json['questions'] as List<dynamic>? ?? [];
    return LessonPage(
      kind: LessonPageKind.values.byName(json['kind'] as String),
      title: json['title'] as String,
      text: json['text'] as String? ?? '',
      pip: json['pip'] as String?,
      terms: (json['terms'] as List<dynamic>? ?? []).cast<String>(),
      options: (json['options'] as List<dynamic>? ?? []).cast<String>(),
      steps: steps
          .map((step) => ExampleStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      questions: questions
          .map(
            (question) =>
                QuizQuestion.fromJson(question as Map<String, dynamic>),
          )
          .toList(),
      passingScore: json['passingScore'] as int? ?? 0,
    );
  }
}
