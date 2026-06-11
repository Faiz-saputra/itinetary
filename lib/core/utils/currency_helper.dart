import 'package:intl/intl.dart';

class CurrencyHelper {
  static String formatRupiah(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  static double parseRupiah(String value) {
    return double.parse(
      value.replaceAll('.', ''),
    );
  }
}