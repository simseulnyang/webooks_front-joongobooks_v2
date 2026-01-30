import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../application/book_provider.dart';
import '../../data/book_api.dart';

class BookEditScreen extends ConsumerStatefulWidget {
  final int bookId;

  const BookEditScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookEditScreen> createState() => _BookEditScreenState();
}

class _BookEditScreenState extends ConsumerState<BookEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _detailInfoController = TextEditingController();

  // Dropdown values
  String _selectedCategory = 'Novel';
  String _selectedSaleCondition = 'For Sale';
  String _selectedCondition = '최상';

  final Map<String, String> _categoryOptions = {
    'Novel': '소설',
    'Social Politic': '사회 정치',
    'Literary Fiction': '인문',
    'Child': '아동',
    'Travel': '여행',
    'History': '역사',
    'Art': '예술',
    'Poem': '시',
    'Science': '과학',
    'Fantasy': '판타지',
    'Magazine': '잡지',
  };

  final Map<String, String> _saleConditionOptions = {
    'For Sale': '판매 중',
    'Reserved': '예약 중',
    'Sold Out': '판매 완료',
  };

  final List<String> _conditionOptions = ['최상', '상', '중', '하'];

  // ✅ 이미지 관련
  File? _selectedImage; // 새로 선택한 이미지
  bool _isFormInitialized = false;
  bool _isSubmitting = false;

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

  void _initializeForm(dynamic book) {
    if (_isFormInitialized || book == null) return;

    _titleController.text = book.title ?? '';
    _authorController.text = book.author ?? '';
    _publisherController.text = book.publisher ?? '';
    _originalPriceController.text = book.originalPrice?.toString() ?? '';
    _sellingPriceController.text = book.sellingPrice?.toString() ?? '';
    _detailInfoController.text = book.detailInfo ?? '';
    _selectedCategory = book.category ?? 'Novel';
    _selectedSaleCondition = book.saleCondition ?? 'For Sale';
    _selectedCondition = book.condition ?? '최상';

    _isFormInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(bookDetailProvider(widget.bookId));

    if (detailState.isLoading) {
      return const Scaffold(body: AppLoading(message: '책 정보를 불러오는 중...'));
    }

    if (detailState.error != null || detailState.book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('책 수정')),
        body: ErrorView(
          message: detailState.error ?? '책 정보를 찾을 수 없습니다.',
          onRetry: () {
            ref
                .read(bookDetailProvider(widget.bookId).notifier)
                .loadBookDetail();
          },
        ),
      );
    }

    // 폼 초기화
    _initializeForm(detailState.book);

    return Scaffold(
      appBar: AppBar(title: const Text('책 수정')),
      body: _isSubmitting
          ? const AppLoading(message: '책을 수정하는 중...')
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ✅ 책 이미지 (기존 이미지 표시 + 변경 가능)
                  _buildImageSection(detailState.book!.bookImage),
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

                  // 판매 상태
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSaleCondition,
                    decoration: const InputDecoration(
                      labelText: '판매 상태',
                      prefixIcon: Icon(Icons.sell),
                    ),
                    items: _saleConditionOptions.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSaleCondition = value!;
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
                      hintText: '원가를 입력하세요',
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: '원',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '원가를 입력해주세요';
                      }
                      if (int.tryParse(value.replaceAll(',', '')) == null) {
                        return '올바른 숫자를 입력해주세요';
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
                      hintText: '판매가를 입력하세요',
                      prefixIcon: Icon(Icons.money),
                      suffixText: '원',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '판매가를 입력해주세요';
                      }
                      if (int.tryParse(value.replaceAll(',', '')) == null) {
                        return '올바른 숫자를 입력해주세요';
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

                  // 수정 버튼
                  AppButton(
                    text: '수정하기',
                    onPressed: _handleSubmit,
                    isLoading: _isSubmitting,
                  ),
                ],
              ),
            ),
    );
  }

  /// ✅ 이미지 섹션 (기존 이미지 표시 + 새로 선택 가능)
  Widget _buildImageSection(String? currentImageUrl) {
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
            : currentImageUrl != null && currentImageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  currentImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                ),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
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
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  /// ✅ 이미지 선택
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

  /// ✅ 책 수정 (이미지 포함)
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
        'sale_condition': _selectedSaleCondition,
        'original_price': int.parse(
          _originalPriceController.text.replaceAll(',', ''),
        ),
        'selling_price': int.parse(
          _sellingPriceController.text.replaceAll(',', ''),
        ),
        'detail_info': _detailInfoController.text.trim(),
      };

      // ✅ 이미지 경로 전달 (새로 선택한 경우만)
      final bookApi = ref.read(bookApiProvider);
      await bookApi.updateBook(
        widget.bookId,
        bookData,
        imagePath: _selectedImage?.path,
      );

      if (mounted) {
        // 상세 화면 새로고침
        ref.read(bookDetailProvider(widget.bookId).notifier).loadBookDetail();
        // 목록 새로고침
        ref.read(bookListProvider.notifier).refresh();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('책이 성공적으로 수정되었습니다!'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('책 수정 실패: $e'),
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
