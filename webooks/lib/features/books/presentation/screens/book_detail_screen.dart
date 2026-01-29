import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../features/auth/application/auth_provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../application/book_provider.dart';
import '../../../chat/data/chat_api.dart';

// 디버깅
import '../../../../core/utils/logger_provider.dart';

/// 책 상세 화면
class BookDetailScreen extends ConsumerStatefulWidget {
  final int bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookDetailProvider(widget.bookId).notifier).loadBookDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(bookDetailProvider(widget.bookId));
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('책 상세'),
        actions: [
          // 좋아요 버튼 (로그인 시에만)
          if (authState.isLoggedIn && detailState.book != null)
            IconButton(
              icon: Icon(
                detailState.book!.isLiked == true
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: detailState.book!.isLiked == true ? Colors.red : null,
              ),
              onPressed: () async {
                await ref
                    .read(bookDetailProvider(widget.bookId).notifier)
                    .toggleFavorite();
              },
            ),

          // 더보기 메뉴 (내가 쓴 글인 경우)
          if (authState.isLoggedIn &&
              detailState.book != null &&
              detailState.book!.writer == authState.user?.id)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreMenu(context),
            ),
        ],
      ),
      body: _buildBody(detailState),
      bottomNavigationBar: authState.isLoggedIn
          ? _buildBottomBar(detailState)
          : null,
    );
  }

  Widget _buildBody(dynamic detailState) {
    // 로딩
    if (detailState.isLoading) {
      return const AppLoading(message: '책 정보를 불러오는 중...');
    }

    // 에러
    if (detailState.error != null) {
      return ErrorView(
        message: detailState.error!,
        onRetry: () {
          ref.read(bookDetailProvider(widget.bookId).notifier).loadBookDetail();
        },
      );
    }

    // 책 정보 없음
    if (detailState.book == null) {
      return const Center(child: Text('책 정보를 찾을 수 없습니다.'));
    }

    final book = detailState.book!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 이미지
          if (book.bookImage != null && book.bookImage!.isNotEmpty)
            Image.network(
              book.bookImage!,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            )
          else
            _buildPlaceholderImage(),

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
                    color: _getStatusColor(
                      book.saleCondition,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    book.saleConditionKorean,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _getStatusColor(book.saleCondition),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 책 제목
                Text(book.title, style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),

                // 저자, 출판사
                Text(
                  '${book.author} · ${book.publisher}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // 가격
                Row(
                  children: [
                    Text(
                      _formatPrice(book.originalPrice),
                      style: AppTextStyles.bodySmall.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatPrice(book.sellingPrice),
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
                _buildInfoRow('책 상태', book.condition),
                const SizedBox(height: 12),

                // 카테고리
                _buildInfoRow('카테고리', book.categoryKorean),
                const SizedBox(height: 12),

                // 등록일
                _buildInfoRow('등록일', book.createdAt),
                const SizedBox(height: 12),

                // 좋아요 수
                _buildInfoRow('좋아요', '${book.likeCount}개'),
                const SizedBox(height: 24),

                // 상세 정보
                Text('상세 정보', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(book.detailInfo, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 300,
      color: AppColors.background,
      child: const Icon(Icons.book, size: 100, color: AppColors.textHint),
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
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  Widget _buildBottomBar(dynamic detailState) {
    if (detailState.book == null) return const SizedBox.shrink();

    final authState = ref.watch(authProvider);
    final isMyBook = detailState.book!.writer == authState.user?.id;

    // 내가 쓴 글이면 채팅 버튼 안 보임
    if (isMyBook) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton(
          text: '채팅하기',
          onPressed: () => _startChat(context, detailState.book!.id),
          icon: Icons.chat_bubble_outline,
        ),
      ),
    );
  }

  /// 채팅 시작 (디버그 버전)
  void _startChat(BuildContext context, int bookId) async {
    final logger = ref.read(loggerProvider);

    try {
      logger.d('🚀 [채팅 시작] bookId: $bookId');

      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      logger.d('📡 [채팅방 생성] API 호출 중...');

      // 채팅방 생성 또는 기존 채팅방 조회
      final chatApi = ref.read(chatApiProvider);
      final chatRoom = await chatApi.createOrGetChatRoom(bookId);

      logger.d('✅ [채팅방 생성] 성공!');
      logger.d('   roomId: ${chatRoom.id}');
      logger.d('   seller: ${chatRoom.seller.username}');
      logger.d('   buyer: ${chatRoom.buyer.username}');

      if (!context.mounted) {
        logger.w('⚠️ [화면 이동] context가 unmounted');
        return;
      }

      // 로딩 닫기
      logger.d('🔄 [로딩 닫기]');
      Navigator.pop(context);

      logger.d('🚀 [화면 이동] ChatRoomScreen으로 이동');
      logger.d(
        '   arguments: roomId=${chatRoom.id}, otherUserName=${chatRoom.seller.username}',
      );

      // 채팅방으로 이동
      Navigator.pushNamed(
        context,
        AppRoutes.chatRoom,
        arguments: {
          'roomId': chatRoom.id,
          'otherUserName': chatRoom.seller.username,
        },
      );

      logger.d('✅ [화면 이동] pushNamed 호출 완료');
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e('❌ [채팅 시작 실패]', error: e, stackTrace: stackTrace);

      if (context.mounted) {
        // 로딩 닫기
        Navigator.pop(context);

        // 에러 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('채팅방 생성 실패: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // void _startChat(BuildContext context, int bookId) async {
  //   try {
  //     // 로딩 표시
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => const Center(child: CircularProgressIndicator()),
  //     );

  //     // 채팅방 생성 또는 기존 채팅방 조회
  //     final chatApi = ref.read(chatApiProvider);
  //     final chatRoom = await chatApi.createOrGetChatRoom(bookId);

  //     if (context.mounted) {
  //       // 로딩 닫기
  //       Navigator.pop(context);

  //       // 채팅방으로 이동
  //       Navigator.pushNamed(
  //         context,
  //         AppRoutes.chatRoom,
  //         arguments: {
  //           'roomId': chatRoom.id,
  //           'otherUserName': chatRoom.seller.username,
  //         },
  //       );
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       // 로딩 닫기
  //       Navigator.pop(context);

  //       // 에러 메시지
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('채팅방 생성 실패: $e'),
  //           backgroundColor: AppColors.error,
  //         ),
  //       );
  //     }
  //   }
  // }

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
                  Navigator.pushNamed(
                    context,
                    AppRoutes.bookEdit,
                    arguments: widget.bookId,
                  );
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
                  _showDeleteDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('책 삭제'),
        content: const Text('정말 삭제하시겠습니까?\n삭제된 책은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // 다이얼로그 닫기

              try {
                // 삭제 실행
                await ref
                    .read(bookDetailProvider(widget.bookId).notifier)
                    .deleteBook();

                if (context.mounted) {
                  // 목록 새로고침
                  ref.read(bookListProvider.notifier).refresh();

                  // 스낵바 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('책이 삭제되었습니다.'),
                      backgroundColor: AppColors.success,
                    ),
                  );

                  // 상세 화면 닫기
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 실패: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

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

  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '₩${formatter.format(price)}';
  }
}
