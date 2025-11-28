import 'dart:async';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:proxyapp/core/utils/shared_preferences.dart';

class AuthInterceptor implements InterceptorContract {
  final void Function()? onUnauthorized;

  AuthInterceptor({this.onUnauthorized});

  @override
  FutureOr<bool> shouldInterceptRequest() => true;

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final token = await PreferencesHelper.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return request;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() => true;

  @override
  FutureOr<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      await PreferencesHelper.clearToken(); // Limpiar token o sesión
      if (onUnauthorized != null) {
        onUnauthorized!(); // Redirigir al login
      }
    }
    return response;
  }
}
