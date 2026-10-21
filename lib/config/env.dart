/// Valeurs injectées à la compilation avec `--dart-define-from-file=env.json`.
///
/// `String.fromEnvironment` est évalué à la compilation : la valeur doit être
/// lue dans un `const`, sinon elle est toujours vide.
abstract final class Env {
  static const String twelveDataKey = String.fromEnvironment('TWELVE_DATA_KEY');

  static bool get hasTwelveDataKey => twelveDataKey.isNotEmpty;
}
