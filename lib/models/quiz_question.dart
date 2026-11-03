class QuizQuestion {
  final String question;
  final List<String> choices;
  final int answerIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.choices,
    required this.answerIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      choices: (json['choices'] as List<dynamic>).cast<String>(),
      answerIndex: json['answerIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }
}
