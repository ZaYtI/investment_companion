class PricePoint {
  final DateTime date;
  final double close;

  const PricePoint({required this.date, required this.close});

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      date: DateTime.parse(json['date'] as String),
      close: (json['close'] as num).toDouble(),
    );
  }
}
