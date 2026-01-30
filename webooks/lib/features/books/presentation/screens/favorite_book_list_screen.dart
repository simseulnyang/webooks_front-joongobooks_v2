// lib/features/books/presentation/screens/favorite_book_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/application/auth_provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../application/book_provider.dart';
import '../widgets/favorite_card.dart'; // ✅ favorite 전용 카드

class FavoriteBookListScreen extends ConsumerStatefulWidget {
  const FavoriteBookListScreen({super.key});

  @override
  ConsumerState<FavoriteBookListScreen> createState() =>
      _FavoriteBookListScreenState();
}

class _FavoriteBookListScreenState
    extends ConsumerState<FavoriteBookListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(favoriteBookListProvider.notifier).loadMoreFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final favState = ref.watch(favoriteBookListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('좋아요')),
      body: authState.isLoggedIn
          ? _buildLoggedInView(context, favState)
          : _buildLoggedOutView(context),
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 100),
            const SizedBox(height: 24),
            const Text('로그인이 필요합니다'),
            const SizedBox(height: 8),
            const Text('좋아요한 책을 보려면 로그인 해주세요'),
            const SizedBox(height: 32),
            AppButton(
              text: '로그인하기',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              icon: Icons.login,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, favState) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(favoriteBookListProvider.notifier).refresh();
      },
      child: _buildBody(context, favState),
    );
  }

  Widget _buildBody(BuildContext context, favState) {
    if (favState.isLoading && favState.books.isEmpty) {
      return const AppLoading(message: '좋아요 목록을 불러오는 중...');
    }

    if (favState.error != null && favState.books.isEmpty) {
      return ErrorView(
        message: favState.error!,
        onRetry: () =>
            ref.read(favoriteBookListProvider.notifier).loadFavorites(),
      );
    }

    if (favState.books.isEmpty) {
      return const EmptyView(
        message: '좋아요한 책이 없습니다.',
        icon: Icons.favorite_border,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: favState.books.length + (favState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == favState.books.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: favState.isLoadingMore
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          );
        }

        final book = favState.books[index];
        return FavoriteCard(book: book, index: index);
      },
    );
  }
}
