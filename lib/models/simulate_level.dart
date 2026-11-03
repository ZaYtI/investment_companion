import 'quiz_question.dart';

class SimulateLevel {
  final String instruction;
  final String simulator;
  final Map<String, dynamic> settings;
  final QuizQuestion readingQuestion;
  final List<String> notes;

  const SimulateLevel({
    required this.instruction,
    required this.simulator,
    required this.settings,
    required this.readingQuestion,
    required this.notes,
  });

  factory SimulateLevel.fromJson(Map<String, dynamic> json) {
    return SimulateLevel(
      instruction: json['instruction'] as String,
      simulator: json['simulator'] as String,
      settings: json['settings'] as Map<String, dynamic>,
      readingQuestion: QuizQuestion.fromJson(
        json['readingQuestion'] as Map<String, dynamic>,
      ),
      notes: (json['notes'] as List<dynamic>).cast<String>(),
    );
  }
}
