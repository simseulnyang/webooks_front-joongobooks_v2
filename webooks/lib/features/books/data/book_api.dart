import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/utils/logger_provider.dart';
import '../domain/models/book.dart';

part 'book_api.g.dart';

class BookApi {
  final Dio _dio;
  final Logger _logger;

  BookApi({required Dio dio, required Logger logger})
    : _dio = dio,
      _logger = logger;

  /// 책 목록 조회 (필터링, 검색, 페이지네이션 포함)
  Future<PaginatedResponse<BookListItem>> getBookList({
    int page = 1,
    String? search,
    String? category,
    String? saleCondition,
    int? minPrice,
    int? maxPrice,
    String ordering = '-created_at',
  }) async {
    try {
      _logger.d(
        '📚 책 목록 조회 - page: $page, search: $search, saleCondition: $saleCondition',
      );

      final queryParams = <String, dynamic>{'page': page, 'ordering': ordering};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (saleCondition != null && saleCondition.isNotEmpty) {
        queryParams['sale_condition'] = saleCondition;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice;
      }

      _logger.d('쿼리 파라미터: $queryParams');

      final response = await _dio.get('books/', queryParameters: queryParams);

      _logger.i('✅ 책 목록 조회 성공: ${response.data['count']}건');

      return PaginatedResponse.fromJson(
        response.data,
        (json) => BookListItem.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      _logger.e('❌ 책 목록 조회 실패: ${e.response?.data ?? e.message}');
      _logger.e('요청 URL: ${e.requestOptions.uri}');
      rethrow;
    }
  }

  /// 책 상세 조회
  Future<Book> getBookDetail(int bookId) async {
    try {
      final path = 'books/detail/$bookId/'; // 👈 변수로 분리
      _logger.d('📖 책 상세 조회 - ID: $bookId');
      _logger.d('🔍 요청 경로: $path'); // 👈 경로 출력
      _logger.d('🔍 baseUrl: ${_dio.options.baseUrl}'); // 👈 baseUrl 출력

      final response = await _dio.get(path);

      _logger.i('✅ 책 상세 조회 성공: ${response.data['title']}');
      return Book.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('❌ 책 상세 조회 실패');
      _logger.e('🔍 요청 URL: ${e.requestOptions.uri}'); // 👈 전체 URL
      _logger.e('🔍 baseUrl: ${e.requestOptions.baseUrl}'); // 👈 baseUrl
      _logger.e('🔍 path: ${e.requestOptions.path}'); // 👈 path
      _logger.e('응답 코드: ${e.response?.statusCode}');
      rethrow;
    }
  }

  /// 책 등록
  Future<Book> createBook(Map<String, dynamic> bookData) async {
    try {
      _logger.d('📝 책 등록 - title: ${bookData['title']}');

      final response = await _dio.post('books/create/', data: bookData);

      _logger.i('✅ 책 등록 성공: ${response.data['title']}');

      return Book.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('❌ 책 등록 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  /// 책 수정
  Future<Book> updateBook(int bookId, Map<String, dynamic> bookData) async {
    try {
      _logger.d('✏️ 책 수정 - ID: $bookId');

      final response = await _dio.patch(
        'books/update/$bookId/',
        data: bookData,
      );

      _logger.i('✅ 책 수정 성공: ${response.data['title']}');

      return Book.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('❌ 책 수정 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  /// 책 삭제
  Future<void> deleteBook(int bookId) async {
    try {
      _logger.d('🗑️ 책 삭제 - ID: $bookId');

      await _dio.delete('books/delete/$bookId/');

      _logger.i('✅ 책 삭제 성공');
    } on DioException catch (e) {
      _logger.e('❌ 책 삭제 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  /// 좋아요 토글
  Future<Map<String, dynamic>> toggleFavorite(int bookId) async {
    try {
      _logger.d('❤️ 좋아요 토글 - Book ID: $bookId');

      final response = await _dio.post('books/$bookId/favorite/');

      _logger.i('✅ 좋아요 토글 성공: ${response.data['message']}');

      return response.data;
    } on DioException catch (e) {
      _logger.e('❌ 좋아요 토글 실패: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  /// 좋아요한 책 목록 조회
  Future<PaginatedResponse<BookListItem>> getFavoriteBooks({
    int page = 1,
  }) async {
    try {
      _logger.d('💖 좋아요 목록 조회 - page: $page');

      final response = await _dio.get(
        'books/favorites/',
        queryParameters: {'page': page},
      );

      _logger.i('✅ 좋아요 목록 조회 성공: ${response.data['count']}건');
      _logger.d('응답 데이터: ${response.data}');

      // Favorite 모델의 book 필드를 추출
      final results = (response.data['results'] as List).map((item) {
        _logger.d('Favorite 아이템: $item');
        final bookData = item['book'] as Map<String, dynamic>;
        _logger.d('Book 데이터: $bookData');
        return BookListItem.fromJson(bookData);
      }).toList();

      return PaginatedResponse<BookListItem>(
        count: response.data['count'],
        next: response.data['next'],
        previous: response.data['previous'],
        results: results,
      );
    } on DioException catch (e) {
      _logger.e('❌ 좋아요 목록 조회 실패: ${e.response?.data ?? e.message}');
      _logger.e('요청 URL: ${e.requestOptions.uri}');
      _logger.e('응답 코드: ${e.response?.statusCode}');
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('❌ 좋아요 목록 파싱 실패', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

@riverpod
BookApi bookApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return BookApi(dio: dio, logger: logger);
}
