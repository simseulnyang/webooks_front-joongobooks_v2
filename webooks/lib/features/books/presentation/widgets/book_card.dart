import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../features/auth/application/auth_provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../application/book_provider.dart';
import '../../domain/models/book.dart';

/// 책 목록 카드 위젯
/// - 왼쪽: 번호, 제목
/// - 오른쪽: 가격, 등록날짜, 좋아요
class BookCard extends ConsumerWidget {
  final BookListItem book;
  final int index; // 목록 번호

  const BookCard({super.key, required this.book, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () {
          // 상세 화면으로 이동
          Navigator.pushNamed(
            context,
            AppRoutes.bookDetail,
            arguments: book.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 번호 + 제목 + 판매 상태
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 번호
                    Text(
                      '#${index + 1}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 제목
                    Text(
                      book.title,
                      style: AppTextStyles.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 저자
                    Text(
                      book.author,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 판매 상태 배지
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          book.saleCondition,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getSaleConditionKorean(book.saleCondition),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getStatusColor(book.saleCondition),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 오른쪽: 가격, 날짜, 좋아요
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 가격
                  Text(
                    _formatPrice(book.sellingPrice),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 등록날짜
                  Text(
                    book.updatedAt,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 좋아요 버튼 (로그인 시에만 클릭 가능)
                  authState.isLoggedIn
                      ? InkWell(
                          onTap: () async {
                            // 좋아요 토글
                            await ref
                                .read(bookListProvider.notifier)
                                .toggleFavorite(book.id);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: book.likeCount > 0
                                      ? Colors.red
                                      : AppColors.textHint,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${book.likeCount}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 16,
                              color: book.likeCount > 0
                                  ? Colors.red
                                  : AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${book.likeCount}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 가격 포맷팅 (예: 15000 → ₩15,000)
  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '₩${formatter.format(price)}';
  }

  /// 판매 상태 한글 변환
  String _getSaleConditionKorean(String status) {
    switch (status) {
      case 'For Sale':
        return '판매중';
      case 'Reserved':
        return '예약중';
      case 'Sold Out':
        return '판매완료';
      default:
        return status;
    }
  }

  /// 판매 상태에 따른 색상
  Color _getStatusColor(String status) {
    switch (status) {
      case 'For Sale':
        return AppColors.success;
      case 'Reserved':
        return AppColors.warning;
      case 'Sold Out':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
