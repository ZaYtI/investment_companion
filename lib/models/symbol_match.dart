class SymbolMatch {
  final String symbol;
  final String name;
  final String exchange;
  final String type;

  const SymbolMatch({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.type,
  });

  factory SymbolMatch.fromJson(Map<String, dynamic> json) {
    return SymbolMatch(
      symbol: json['symbol'] as String,
      name: json['instrument_name'] as String,
      exchange: json['exchange'] as String,
      type: json['instrument_type'] as String,
    );
  }
}
