import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/app_button.dart';

/// 책 상세 화면
class BookDetailScreen extends ConsumerStatefulWidget {
  final int bookId;

  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: 책 상세 정보 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('책 상세'),
        actions: [
          // 좋아요 버튼
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: 좋아요 토글
            },
          ),
          // 더보기 메뉴 (내가 쓴 글인 경우)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showMoreMenu(context);
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    // TODO: Provider 연결
    final isLoading = false;
    final hasError = false;

    if (isLoading) {
      return const AppLoading(message: '책 정보를 불러오는 중...');
    }

    if (hasError) {
      return ErrorView(
        message: '책 정보를 불러오는데 실패했습니다.',
        onRetry: () {
          // TODO: 재시도
        },
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 이미지
          Container(
            width: double.infinity,
            height: 300,
            color: AppColors.background,
            child: const Icon(
              Icons.book,
              size: 100,
              color: AppColors.textHint,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 판매 상태
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '판매중',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 책 제목
                Text(
                  '해리포터와 마법사의 돌',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 8),

                // 저자, 출판사
                Text(
                  'J.K. 롤링 · 문학수첩',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // 가격
                Row(
                  children: [
                    Text(
                      '₩ 20,000',
                      style: AppTextStyles.bodySmall.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₩ 15,000',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 구분선
                const Divider(),
                const SizedBox(height: 16),

                // 책 상태
                _buildInfoRow('책 상태', '최상'),
                const SizedBox(height: 12),

                // 카테고리
                _buildInfoRow('카테고리', '소설'),
                const SizedBox(height: 24),

                // 상세 정보
                Text(
                  '상세 정보',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '책이 정말 깨끗합니다. 거의 새 책 수준이에요!',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton(
          text: '채팅하기',
          onPressed: () {
            // TODO: 채팅방으로 이동
          },
          icon: Icons.chat_bubble_outline,
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('수정하기'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 수정 화면으로 이동
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text(
                  '삭제하기',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 삭제 확인 다이얼로그
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
