import 'package:intl/intl.dart';

class NumberFormatter {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(number);
  }
}