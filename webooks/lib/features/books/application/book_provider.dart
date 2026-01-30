import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../data/book_api.dart';
import '../domain/models/book.dart';
import 'favorite_state.dart';
import '../../../core/error/api_error.dart';
import '../../../core/utils/logger_provider.dart';
import 'book_state.dart';

part 'book_provider.g.dart';

/// 책 목록 Provider
@riverpod
class BookList extends _$BookList {
  @override
  BookListState build() {
    // 초기 로드
    loadBooks();
    return const BookListState();
  }

  /// 책 목록 로드 (첫 페이지)
  Future<void> loadBooks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bookApi = ref.read(bookApiProvider);
      final logger = ref.read(loggerProvider);

      logger.d('🔄 책 목록 로드 시작');

      final response = await bookApi.getBookList(
        page: 1,
        search: state.searchQuery,
        saleCondition: state.selectedSaleCondition,
        category: state.selectedCategory,
      );

      state = state.copyWith(
        books: response.results,
        isLoading: false,
        currentPage: 1,
        hasMore: response.hasNext,
        totalCount: response.count,
      );

      logger.d('✅ 책 목록 로드 완료: ${response.results.length}건');
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 책 목록 로드 실패', error: e);

      final apiError = ApiError.fromDioException(e);
      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 예상치 못한 오류', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        error: '책 목록을 불러오는 중 오류가 발생했습니다.',
      );
    }
  }

  /// 다음 페이지 로드 (무한 스크롤)
  Future<void> loadMoreBooks() async {
    // 이미 로딩 중이거나 더 이상 페이지가 없으면 중단
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final bookApi = ref.read(bookApiProvider);
      final logger = ref.read(loggerProvider);
      final nextPage = state.currentPage + 1;

      logger.d('🔄 다음 페이지 로드: $nextPage');

      final response = await bookApi.getBookList(
        page: nextPage,
        search: state.searchQuery,
        saleCondition: state.selectedSaleCondition,
        category: state.selectedCategory,
      );

      state = state.copyWith(
        books: [...state.books, ...response.results],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: response.hasNext,
      );

      logger.d('✅ 다음 페이지 로드 완료: ${response.results.length}건');
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 다음 페이지 로드 실패', error: e);

      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// 검색어 설정 및 재검색
  Future<void> setSearchQuery(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(currentPage: 1, books: [], clearSearchQuery: true);
    } else {
      state = state.copyWith(searchQuery: query, currentPage: 1, books: []);
    }
    await loadBooks();
  }

  /// 판매 상태 필터 설정
  Future<void> setSaleConditionFilter(String? condition) async {
    // null이면 전체 보기 (필터 해제)
    if (condition == null || condition.isEmpty) {
      state = state.copyWith(
        currentPage: 1,
        books: [],
        clearSaleCondition: true,
      );
    } else {
      state = state.copyWith(
        selectedSaleCondition: condition,
        currentPage: 1,
        books: [],
      );
    }
    await loadBooks();
  }

  /// 카테고리 필터 설정
  Future<void> setCategoryFilter(String? category) async {
    if (category == null || category.isEmpty) {
      state = state.copyWith(currentPage: 1, books: [], clearCategory: true);
    } else {
      state = state.copyWith(
        selectedCategory: category,
        currentPage: 1,
        books: [],
      );
    }
    await loadBooks();
  }

  /// 필터 초기화
  Future<void> clearFilters() async {
    state = state.clearFilters();
    await loadBooks();
  }

  /// 새로고침
  Future<void> refresh() async {
    state = state.copyWith(currentPage: 1, books: []);
    await loadBooks();
  }

  /// 좋아요 토글 (로컬 상태 업데이트)
  Future<void> toggleFavorite(int bookId) async {
    try {
      final bookApi = ref.read(bookApiProvider);

      await bookApi.toggleFavorite(bookId);

      // 전체 새로고침 (가장 확실한 방법)
      await refresh();
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 좋아요 토글 실패', error: e);
      rethrow;
    }
  }
}

/// 책 상세 Provider
@riverpod
class BookDetail extends _$BookDetail {
  @override
  BookDetailState build(int bookId) {
    Future.microtask(loadBookDetail);

    return const BookDetailState();
  }

  Future<void> loadBookDetail() async {
    state = BookDetailState(isLoading: true);

    try {
      final bookApi = ref.read(bookApiProvider);
      final logger = ref.read(loggerProvider);

      logger.d('🔄 책 상세 로드: $bookId');

      final book = await bookApi.getBookDetail(bookId);

      state = state.copyWith(book: book, isLoading: false);

      logger.d('✅ 책 상세 로드 완료: ${book.title}');
    } on DioException catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 책 상세 로드 실패', error: e);

      final apiError = ApiError.fromDioException(e);
      state = state.copyWith(isLoading: false, error: apiError.message);
    }
  }

  /// 좋아요 토글
  Future<void> toggleFavorite() async {
    if (state.book == null) return;

    try {
      final bookApi = ref.read(bookApiProvider);
      await bookApi.toggleFavorite(state.book!.id);

      // 상세 정보 다시 로드
      await loadBookDetail();
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 좋아요 토글 실패', error: e);
      rethrow;
    }
  }

  /// 책 삭제
  Future<void> deleteBook() async {
    if (state.book == null) return;

    try {
      final bookApi = ref.read(bookApiProvider);
      final logger = ref.read(loggerProvider);

      logger.d('🗑️ 책 삭제 시작: ${state.book!.id}');

      await bookApi.deleteBook(state.book!.id);

      logger.d('✅ 책 삭제 완료');
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ 책 삭제 실패', error: e);
      rethrow;
    }
  }
}

/// 좋아요한 책 목록 Provider
@riverpod
class FavoriteBookList extends _$FavoriteBookList {
  @override
  FavoriteState build() {
    Future.microtask(loadFavorites);
    return const FavoriteState();
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);

    final logger = ref.read(loggerProvider);

    try {
      logger.d('💖 좋아요 목록 로드 시작');

      final bookApi = ref.read(bookApiProvider);
      final response = await bookApi.getFavoriteBooks(page: 1);

      state = state.copyWith(
        books: response.results,
        isLoading: false,
        currentPage: 1,
        hasMore: response.hasNext,
        totalCount: response.count,
      );

      logger.d('✅ 좋아요 목록 로드 완료');
    } on DioException catch (e) {
      final apiError = ApiError.fromDioException(e);
      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e) {
      logger.e('❌ 좋아요 목록 로드 실패', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMoreFavorites() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final bookApi = ref.read(bookApiProvider);
      final response = await bookApi.getFavoriteBooks(page: nextPage);

      state = state.copyWith(
        books: [...state.books, ...response.results],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: response.hasNext,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(currentPage: 1, books: []);
    await loadFavorites();
  }
}
