import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Slow connection or timeout. Check your internet and retry.';
      case DioExceptionType.connectionError:
        return 'Cannot reach the server. Check your internet connection.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Data not found (404).';
        if (code == 401 || code == 403) {
          return 'Access denied ($code). Check your credentials.';
        }
        return 'Server problem ($code). Try again later.';
      default:
        return 'A network error occurred. Try again.';
    }
  }
  return 'An unexpected error occurred: $error';
}
