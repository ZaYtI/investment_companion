import 'chapter_context.dart';

class ChapterSummary {
  final int number;
  final String title;
  final String period;
  final String intro;
  final String challenge;
  final ChapterContext? context;

  const ChapterSummary({
    required this.number,
    required this.title,
    required this.period,
    required this.intro,
    required this.challenge,
    required this.context,
  });

  factory ChapterSummary.fromJson(Map<String, dynamic> json) {
    return ChapterSummary(
      number: json['number'] as int,
      title: json['title'] as String,
      period: json['period'] as String,
      intro: json['intro'] as String,
      challenge: json['challenge'] as String,
      context: json['context'] == null
          ? null
          : ChapterContext.fromJson(json['context'] as Map<String, dynamic>),
    );
  }
}
