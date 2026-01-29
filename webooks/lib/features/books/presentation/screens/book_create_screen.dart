import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../application/book_provider.dart';
import '../../data/book_api.dart';

/// 책 등록 화면
class BookCreateScreen extends ConsumerStatefulWidget {
  const BookCreateScreen({super.key});

  @override
  ConsumerState<BookCreateScreen> createState() => _BookCreateScreenState();
}

class _BookCreateScreenState extends ConsumerState<BookCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _detailInfoController = TextEditingController();

  String _selectedCategory = 'Novel';
  String _selectedCondition = '최상';
  File? _selectedImage;
  bool _isSubmitting = false;

  // 카테고리 옵션 (영문 -> 한글)
  final Map<String, String> _categoryOptions = {
    'Social Politic': '사회 정치',
    'Literary Fiction': '인문',
    'Child': '아동',
    'Travel': '여행',
    'History': '역사',
    'Art': '예술',
    'Novel': '소설',
    'Poem': '시',
    'Science': '과학',
    'Fantasy': '판타지',
    'Magazine': '잡지',
  };

  // 책 상태 옵션
  final List<String> _conditionOptions = ['최상', '상', '중', '하'];

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
      appBar: AppBar(title: const Text('책 등록')),
      body: _isSubmitting
          ? const AppLoading(message: '책을 등록하는 중...')
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 책 이미지 선택
                  _buildImageSection(),
                  const SizedBox(height: 24),

                  // 제목
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '책 제목',
                      hintText: '책 제목을 입력하세요',
                      prefixIcon: Icon(Icons.book),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
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
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
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
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
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
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categoryOptions.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
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
                      prefixIcon: Icon(Icons.star),
                    ),
                    items: _conditionOptions
                        .map(
                          (condition) => DropdownMenuItem(
                            value: condition,
                            child: Text(condition),
                          ),
                        )
                        .toList(),
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
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '원가를 입력해주세요';
                      }
                      if (int.tryParse(value.replaceAll(',', '')) == null) {
                        return '올바른 금액을 입력해주세요';
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
                      prefixIcon: Icon(Icons.sell),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '판매가를 입력해주세요';
                      }
                      if (int.tryParse(value.replaceAll(',', '')) == null) {
                        return '올바른 금액을 입력해주세요';
                      }
                      return null;
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
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.description),
                      ),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '상세 정보를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // 등록 버튼
                  AppButton(
                    text: '등록하기',
                    onPressed: _handleSubmit,
                    isLoading: _isSubmitting,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Center(
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
                      '사진 추가 (선택)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final bookData = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'publisher': _publisherController.text.trim(),
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'original_price': int.parse(
          _originalPriceController.text.replaceAll(',', ''),
        ),
        'selling_price': int.parse(
          _sellingPriceController.text.replaceAll(',', ''),
        ),
        'detail_info': _detailInfoController.text.trim(),
      };

      // TODO: 이미지가 있으면 multipart/form-data로 전송 필요
      // 현재는 JSON만 전송
      final bookApi = ref.read(bookApiProvider);
      await bookApi.createBook(bookData);

      if (mounted) {
        // 책 목록 새로고침
        ref.read(bookListProvider.notifier).refresh();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('책이 성공적으로 등록되었습니다!'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('책 등록 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
