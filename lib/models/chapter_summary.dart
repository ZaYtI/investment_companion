class ChapterSummary {
  final int number;
  final String title;
  final String period;

  const ChapterSummary({
    required this.number,
    required this.title,
    required this.period,
  });

  factory ChapterSummary.fromJson(Map<String, dynamic> json) {
    return ChapterSummary(
      number: json['number'] as int,
      title: json['title'] as String,
      period: json['period'] as String,
    );
  }
}
