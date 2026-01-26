import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

/// 책 수정 화면
class BookEditScreen extends ConsumerStatefulWidget {
  final int bookId;

  const BookEditScreen({
    super.key,
    required this.bookId,
  });

  @override
  ConsumerState<BookEditScreen> createState() => _BookEditScreenState();
}

class _BookEditScreenState extends ConsumerState<BookEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _detailInfoController = TextEditingController();

  String _selectedCategory = 'Novel';
  String _selectedCondition = '최상';
  String _selectedSaleCondition = 'For Sale';

  @override
  void initState() {
    super.initState();
    // TODO: 기존 책 정보 로드
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _originalPriceController.dispose();
    _sellingPriceController.dispose();
    _detailInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('책 수정'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 책 이미지
            _buildImageSection(),
            const SizedBox(height: 24),

            // 제목
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '책 제목',
                hintText: '책 제목을 입력하세요',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '책 제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 저자
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: '저자',
                hintText: '저자를 입력하세요',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '저자를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 출판사
            TextFormField(
              controller: _publisherController,
              decoration: const InputDecoration(
                labelText: '출판사',
                hintText: '출판사를 입력하세요',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '출판사를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 카테고리
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '카테고리',
              ),
              items: const [
                DropdownMenuItem(value: 'Novel', child: Text('소설')),
                DropdownMenuItem(value: 'Essay', child: Text('에세이')),
                DropdownMenuItem(value: 'Science', child: Text('과학')),
                // TODO: 나머지 카테고리 추가
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 책 상태
            DropdownButtonFormField<String>(
              initialValue: _selectedCondition,
              decoration: const InputDecoration(
                labelText: '책 상태',
              ),
              items: const [
                DropdownMenuItem(value: '최상', child: Text('최상')),
                DropdownMenuItem(value: '상', child: Text('상')),
                DropdownMenuItem(value: '중', child: Text('중')),
                DropdownMenuItem(value: '하', child: Text('하')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 원가
            TextFormField(
              controller: _originalPriceController,
              decoration: const InputDecoration(
                labelText: '원가',
                hintText: '원래 가격을 입력하세요',
                prefixText: '₩ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '원가를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 판매가
            TextFormField(
              controller: _sellingPriceController,
              decoration: const InputDecoration(
                labelText: '판매가',
                hintText: '판매 가격을 입력하세요',
                prefixText: '₩ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '판매가를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 판매 상태
            DropdownButtonFormField<String>(
              initialValue: _selectedSaleCondition,
              decoration: const InputDecoration(
                labelText: '판매 상태',
              ),
              items: const [
                DropdownMenuItem(value: 'For Sale', child: Text('판매중')),
                DropdownMenuItem(value: 'Reserved', child: Text('예약중')),
                DropdownMenuItem(value: 'Sold Out', child: Text('판매완료')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSaleCondition = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 상세 정보
            TextFormField(
              controller: _detailInfoController,
              decoration: const InputDecoration(
                labelText: '상세 정보',
                hintText: '책에 대한 상세한 설명을 입력하세요',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '상세 정보를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // 수정 버튼
            AppButton(
              text: '수정하기',
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 60,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 8),
            Text(
              '사진 변경',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // TODO: 수정 로직
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('책 정보가 수정되었습니다')),
      );
    }
  }
}
