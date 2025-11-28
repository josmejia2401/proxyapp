import 'package:intl/intl.dart';

class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  static String? Function(String?) minLength(int min) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      return value.length < min ? 'Debe tener al menos $min caracteres' : null;
    };
  }

  static String? Function(String?) maxLength(int max) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      return value.length > max ? 'No debe superar los $max caracteres' : null;
    };
  }

  static String? alphaNumeric(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(value)
        ? null
        : 'Solo se permiten letras y números (sin espacios ni símbolos)';
  }

  static String? alphaNumericWithSpaces(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^[a-zA-Z0-9\s]+$');
    return regex.hasMatch(value)
        ? null
        : 'Solo se permiten letras, números y espacios';
  }

  static String? alphaNumericWithSpacesAndAccent(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ0-9\s]+$');
    return regex.hasMatch(value)
        ? null
        : 'Solo se permiten letras (con tilde), números y espacios';
  }

  static String? validDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La fecha es obligatoria';
    }
    try {
      final date = DateFormat('dd/MM/yyyy').parseStrict(value);
      if (date.isAfter(DateTime.now())) {
        return 'La fecha no puede ser en el futuro';
      }
    } catch (_) {
      return 'Formato de fecha inválido. Usa dd/MM/yyyy';
    }
    return null;
  }

  static String? validEmail(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return regex.hasMatch(value) ? null : 'Correo electrónico inválido';
  }
}
