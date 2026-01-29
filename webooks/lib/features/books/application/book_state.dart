import '../domain/models/book.dart';

/// 책 목록 상태
class BookListState {
  final List<BookListItem> books;
  final bool isLoading;
  final bool isLoadingMore; // 다음 페이지 로딩 중
  final String? error;
  final int currentPage;
  final bool hasMore; // 다음 페이지 존재 여부
  final int totalCount; // 전체 책 개수

  // 필터 & 검색 상태
  final String? searchQuery;
  final String? selectedCategory;
  final String? selectedSaleCondition;

  const BookListState({
    this.books = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.totalCount = 0,
    this.searchQuery,
    this.selectedCategory,
    this.selectedSaleCondition,
  });

  BookListState copyWith({
    List<BookListItem>? books,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    int? totalCount,
    String? searchQuery,
    String? selectedCategory,
    String? selectedSaleCondition,
    bool clearSaleCondition = false, // 판매 상태 초기화 플래그
    bool clearCategory = false, // 카테고리 초기화 플래그
    bool clearSearchQuery = false, // 검색어 초기화 플래그
  }) {
    return BookListState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedSaleCondition: clearSaleCondition
          ? null
          : (selectedSaleCondition ?? this.selectedSaleCondition),
    );
  }

  /// 필터 초기화
  BookListState clearFilters() {
    return copyWith(
      searchQuery: '',
      selectedCategory: '',
      selectedSaleCondition: '',
      currentPage: 1,
      books: [],
      clearSearchQuery: true,
      clearCategory: true,
      clearSaleCondition: true,
    );
  }
}

/// 책 상세 상태
class BookDetailState {
  final Book? book;
  final bool isLoading;
  final String? error;

  const BookDetailState({this.book, this.isLoading = false, this.error});

  BookDetailState copyWith({Book? book, bool? isLoading, String? error}) {
    return BookDetailState(
      book: book ?? this.book,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
