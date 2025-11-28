import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = '[Renapp]';

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('$_tag DEBUG: $message');
    }
  }

  static void info(String message) {
    debugPrint('$_tag INFO: $message');
  }

  static void warning(String message) {
    debugPrint('$_tag WARNING: $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('$_tag ERROR: $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    // Aquí puedes integrar con Sentry, Crashlytics u otro servicio
    // Crashlytics.instance.recordError(error, stackTrace);
  }
}
