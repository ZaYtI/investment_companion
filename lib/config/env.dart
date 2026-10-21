abstract final class Env {
  static const String twelveDataKey = String.fromEnvironment('TWELVE_DATA_KEY');

  static bool get hasTwelveDataKey => twelveDataKey.isNotEmpty;
}
