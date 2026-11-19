import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(String iso) {
    final tanggal = DateTime.tryParse(iso);
    if (tanggal == null) return '-';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(tanggal.toLocal());
  }
}