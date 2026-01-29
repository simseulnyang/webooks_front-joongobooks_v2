import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/application/auth_provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../application/book_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/sale_condition_filter.dart';

/// 책 목록 화면 (홈 탭)
class BookListScreen extends ConsumerStatefulWidget {
  const BookListScreen({super.key});

  @override
  ConsumerState<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends ConsumerState<BookListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookListProvider.notifier).loadBooks();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 스크롤 이벤트 - 무한 스크롤
  void _onScroll() {
    // 스크롤이 하단 80%에 도달하면 다음 페이지 로드
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(bookListProvider.notifier).loadMoreBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookListState = ref.watch(bookListProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WeBooks'),
        actions: [
          // 검색 버튼
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 판매 상태 필터 버튼
          SaleConditionFilter(
            selectedCondition: bookListState.selectedSaleCondition,
            onConditionChanged: (condition) {
              ref
                  .read(bookListProvider.notifier)
                  .setSaleConditionFilter(condition);
            },
          ),

          // 현재 필터 정보 (검색어가 있을 때만)
          if (bookListState.searchQuery != null &&
              bookListState.searchQuery!.isNotEmpty)
            _buildSearchInfo(bookListState.searchQuery!),

          const Divider(height: 1),

          // 책 목록
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(bookListProvider.notifier).refresh();
              },
              child: _buildBody(bookListState),
            ),
          ),
        ],
      ),
      floatingActionButton: authState.isLoggedIn
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.bookCreate);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  /// 검색어 정보 표시
  Widget _buildSearchInfo(String query) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primaryLight.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '검색: "$query"',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              _searchController.clear();
              ref.read(bookListProvider.notifier).setSearchQuery('');
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(dynamic bookListState) {
    // 초기 로딩
    if (bookListState.isLoading && bookListState.books.isEmpty) {
      return const AppLoading(message: '책 목록을 불러오는 중...');
    }

    // 에러
    if (bookListState.error != null && bookListState.books.isEmpty) {
      return ErrorView(
        message: bookListState.error!,
        onRetry: () {
          ref.read(bookListProvider.notifier).loadBooks();
        },
      );
    }

    // 빈 목록
    if (bookListState.books.isEmpty) {
      return const EmptyView(
        message: '등록된 책이 없습니다.',
        icon: Icons.book_outlined,
      );
    }

    // 책 목록
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: bookListState.books.length + (bookListState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // 마지막 아이템 - 로딩 인디케이터
        if (index == bookListState.books.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: bookListState.isLoadingMore
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          );
        }

        // 책 카드
        final book = bookListState.books[index];
        return BookCard(book: book, index: index);
      },
    );
  }

  /// 검색 다이얼로그
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('책 검색'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '제목, 저자, 출판사 검색',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            _performSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performSearch(_searchController.text);
            },
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }

  /// 검색 실행
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    ref.read(bookListProvider.notifier).setSearchQuery(query.trim());
  }
}
