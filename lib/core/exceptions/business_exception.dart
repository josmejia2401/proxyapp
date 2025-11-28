class BusinessException implements Exception {
  final String message;
  final int? code;

  BusinessException(this.message, {this.code});

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}
