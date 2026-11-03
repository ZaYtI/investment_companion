class ContextFact {
  final String icon;
  final String text;

  const ContextFact({required this.icon, required this.text});

  factory ContextFact.fromJson(Map<String, dynamic> json) {
    return ContextFact(
      icon: json['icon'] as String,
      text: json['text'] as String,
    );
  }
}

class ChapterContext {
  final String question;
  final List<ContextFact> facts;
  final String figures;
  final List<String> keywords;
  final String afterwards;

  const ChapterContext({
    required this.question,
    required this.facts,
    required this.figures,
    required this.keywords,
    required this.afterwards,
  });

  factory ChapterContext.fromJson(Map<String, dynamic> json) {
    final facts = json['facts'] as List<dynamic>;
    return ChapterContext(
      question: json['question'] as String,
      facts: facts
          .map((fact) => ContextFact.fromJson(fact as Map<String, dynamic>))
          .toList(),
      figures: json['figures'] as String,
      keywords: (json['keywords'] as List<dynamic>).cast<String>(),
      afterwards: json['afterwards'] as String,
    );
  }
}
