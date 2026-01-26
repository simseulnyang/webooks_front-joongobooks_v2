import 'package:dio/dio.dart';

class ApiError {
  final String message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiError({
    required this.message,
    this.errors,
    this.statusCode,
  });

  factory ApiError.fromDioException(DioException e) {
    final response = e.response;

    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      return ApiError(
        message: data['message'] as String? ?? '알 수 없는 오류가 발생했습니다.',
        errors: data['errors'] as Map<String, dynamic>?,
        statusCode: response.statusCode,
      );
    }

    return ApiError(
      message: _getDefaultMessage(e.type),
      statusCode: response?.statusCode,
    );
  }

  static String _getDefaultMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '서버 응답 시간이 초과되었습니다.';
      case DioExceptionType.connectionError:
        return '네트워크 연결에 문제가 발생했습니다.';
      case DioExceptionType.badResponse:
        return '서버에서 오류가 발생했습니다..';
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }

  @override
  String toString() => message;
}
