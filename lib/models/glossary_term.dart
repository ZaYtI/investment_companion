class GlossaryTerm {
  final String id;
  final String term;
  final String definition;

  const GlossaryTerm({
    required this.id,
    required this.term,
    required this.definition,
  });

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) {
    return GlossaryTerm(
      id: json['id'] as String,
      term: json['term'] as String,
      definition: json['definition'] as String,
    );
  }
}
