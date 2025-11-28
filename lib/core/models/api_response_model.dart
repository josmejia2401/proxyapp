abstract class Serializable {
  Map<String, dynamic> toMap();
}

class ApiResponse<T extends Serializable> {
  final int code;
  final String message;
  final T data;

  ApiResponse({required this.code, required this.message, required this.data});

  factory ApiResponse.fromMap(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    return ApiResponse(
      code: map['code'] ?? 0,
      message: map['message'] ?? "",
      data: fromMap(map['data']?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {'code': code, 'message': message, 'data': data.toMap()};
  }

  @override
  String toString() =>
      'ApiResponse(code: $code, message: $message, data: $data)';
}
