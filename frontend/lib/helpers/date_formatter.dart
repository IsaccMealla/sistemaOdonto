import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'No especificada';

    try {
      final dateTime = DateTime.parse(isoDate);
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(dateTime.toLocal());
    } catch (e) {
      return isoDate; // Return original if parsing fails
    }
  }

  static String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'No especificada';

    try {
      final dateTime = DateTime.parse(isoDate);
      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime.toLocal());
    } catch (e) {
      return isoDate;
    }
  }

  static String formatTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'No especificada';

    try {
      final dateTime = DateTime.parse(isoDate);
      final formatter = DateFormat('HH:mm');
      return formatter.format(dateTime.toLocal());
    } catch (e) {
      return isoDate;
    }
  }
}
