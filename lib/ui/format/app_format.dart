import 'package:intl/intl.dart';

abstract final class AppFormat {
  static const locale = 'fr_FR';
  static const minus = '−';
  static const plus = '+';
  static const nonBreakingSpace = ' ';

  static final _euro = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: 0,
  );
  static final _euroWithCents = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: 2,
  );
  static final _percent = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = 1;

  static String euro(double amount, {bool withCents = false}) {
    final digits = (withCents ? _euroWithCents : _euro).format(amount.abs());
    return '${amount < 0 ? minus : ''}$digits$nonBreakingSpace€';
  }

  static String signedEuro(double amount) =>
      '${_sign(amount)}${euro(amount.abs())}';

  static String percent(double fraction) {
    final digits = _percent.format((fraction * 100).abs());
    return '${fraction < 0 ? minus : ''}$digits$nonBreakingSpace%';
  }

  static String signedPercent(double fraction) =>
      '${_sign(fraction)}${percent(fraction.abs())}';

  static String _sign(double value) => switch (value) {
    > 0 => plus,
    < 0 => minus,
    _ => '',
  };
}
