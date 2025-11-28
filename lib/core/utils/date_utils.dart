import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatDateTime(
    DateTime dateTime, {
    String format = 'dd/MM/yyyy HH:mm',
  }) {
    return DateFormat(format).format(dateTime);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static String timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inSeconds < 60) return 'Hace unos segundos';
    if (duration.inMinutes < 60) return 'Hace ${duration.inMinutes} min';
    if (duration.inHours < 24) return 'Hace ${duration.inHours} h';
    return formatDate(dateTime);
  }
}
