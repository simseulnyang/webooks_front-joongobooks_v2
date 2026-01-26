import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';

/// 책 목록 화면 (홈 탭)
class BookListScreen extends ConsumerStatefulWidget {
  const BookListScreen({super.key});

  @override
  ConsumerState<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends ConsumerState<BookListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // TODO: 초기 데이터 로드
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WeBooks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 검색 기능
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: 필터 기능
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: 새로고침
        },
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 책 등록 화면으로 이동
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    // TODO: Provider 연결 후 상태에 따라 UI 변경
    final isLoading = false;
    final hasError = false;
    final books = <dynamic>[];

    if (isLoading) {
      return const AppLoading(message: '책 목록을 불러오는 중...');
    }

    if (hasError) {
      return ErrorView(
        message: '책 목록을 불러오는데 실패했습니다.',
        onRetry: () {
          // TODO: 재시도
        },
      );
    }

    if (books.isEmpty) {
      return const EmptyView(
        message: '등록된 책이 없습니다.',
        icon: Icons.book_outlined,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        // TODO: BookCard 위젯으로 교체
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text('책 제목 ${index + 1}'),
            subtitle: Text('₩ 15,000'),
          ),
        );
      },
    );
  }
}
