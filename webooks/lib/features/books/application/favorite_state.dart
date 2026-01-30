import '../domain/models/book.dart';

class FavoriteState {
  final List<BookListItem> books;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  final int currentPage;
  final bool hasMore;
  final int totalCount;

  const FavoriteState({
    this.books = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = false,
    this.totalCount = 0,
  });

  FavoriteState copyWith({
    List<BookListItem>? books,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    int? totalCount,
  }) {
    return FavoriteState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
