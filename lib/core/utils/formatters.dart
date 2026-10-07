import 'package:intl/intl.dart';

/// Formateadores compartidos (montos en Decimal/ISO 4217 — PRD §8).
abstract final class Formatters {
  static final _currencyCOP = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  static final _date = DateFormat('d MMM yyyy', 'es');
  static final _dateTime = DateFormat('d MMM yyyy, h:mm a', 'es');

  static String currency(num amount, {String currency = 'COP'}) =>
      currency == 'COP' ? _currencyCOP.format(amount) : '$currency $amount';

  static String date(DateTime value) => _date.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);

  /// "Última actualización hace X min" para el indicador de sincronización
  /// (PRD §F3.4).
  static String timeAgo(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'hace un momento';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }
}
