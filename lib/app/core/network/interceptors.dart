import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_constants.dart';

class AppInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ensure API key is set in headers
    options.headers['x-api-key'] = AppConstants.apiKey;

    // Debug logging for development
    if (kDebugMode) {
      print('REQUEST[${options.method}] => URL: ${options.uri}');
      print('HEADERS: ${options.headers}');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Debug logging for development
    if (kDebugMode) {
      print(
          'RESPONSE[${response.statusCode}] => URL: ${response.requestOptions.uri}');
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print(
          'ERROR[${err.response?.statusCode}] => URL: ${err.requestOptions.uri}');
      print('DATA: ${err.response?.data}');
    }
    return super.onError(err, handler);
  }
}
