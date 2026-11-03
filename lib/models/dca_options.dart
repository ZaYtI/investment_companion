class DcaOptions {
  final String assetId;
  final String lastPriceAssetId;
  final DateTime defaultStart;
  final DateTime earliestStart;
  final int minMonthly;
  final int maxMonthly;
  final int stepMonthly;
  final int defaultMonthly;

  const DcaOptions({
    required this.assetId,
    required this.lastPriceAssetId,
    required this.defaultStart,
    required this.earliestStart,
    required this.minMonthly,
    required this.maxMonthly,
    required this.stepMonthly,
    required this.defaultMonthly,
  });

  factory DcaOptions.fromSettings(Map<String, dynamic> settings) {
    final monthly = settings['monthly'] as Map<String, dynamic>;
    final startRange = settings['startRange'] as Map<String, dynamic>;
    return DcaOptions(
      assetId: settings['asset'] as String,
      lastPriceAssetId: settings['finalPriceAsset'] as String,
      defaultStart: _parseMonth(settings['defaultStart'] as String),
      earliestStart: _parseMonth(startRange['from'] as String),
      minMonthly: monthly['min'] as int,
      maxMonthly: monthly['max'] as int,
      stepMonthly: monthly['step'] as int,
      defaultMonthly: monthly['default'] as int,
    );
  }

  static DateTime _parseMonth(String text) => DateTime.parse('$text-01');

  String? validateMonthly(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Indiquez un montant.';
    }
    final amount = int.tryParse(text.trim());
    if (amount == null) {
      return 'Entrez un nombre entier, sans centimes.';
    }
    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0 €.';
    }
    if (amount < minMonthly || amount > maxMonthly) {
      return 'Choisissez entre $minMonthly € et $maxMonthly €.';
    }
    return null;
  }
}
