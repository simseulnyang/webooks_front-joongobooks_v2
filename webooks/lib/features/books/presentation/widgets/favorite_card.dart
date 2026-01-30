// lib/features/books/presentation/widgets/favorite_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../features/auth/application/auth_provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../application/book_provider.dart';
import '../../domain/models/book.dart';

class FavoriteCard extends ConsumerWidget {
  final BookListItem book;
  final int index;

  const FavoriteCard({super.key, required this.book, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${index + 1}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.title,
                      style: AppTextStyles.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _SaleBadge(saleCondition: book.saleCondition),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPrice(book.sellingPrice),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.updatedAt,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: authState.isLoggedIn
                        ? () async {
                            await ref
                                .read(bookListProvider.notifier)
                                .toggleFavorite(book.id);

                            // ✅ 좋아요 목록에서 즉시 반영하고 싶으면 refresh
                            await ref
                                .read(favoriteBookListProvider.notifier)
                                .refresh();
                          }
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite, size: 16, color: Colors.red),
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '₩${formatter.format(price)}';
  }
}

class _SaleBadge extends StatelessWidget {
  final String saleCondition;

  const _SaleBadge({required this.saleCondition});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (saleCondition) {
      case 'For Sale':
        color = AppColors.success;
        label = '판매중';
        break;
      case 'Reserved':
        color = AppColors.warning;
        label = '예약중';
        break;
      case 'Sold Out':
        color = AppColors.error;
        label = '판매완료';
        break;
      default:
        color = AppColors.textSecondary;
        label = saleCondition;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 11),
      ),
    );
  }
}
