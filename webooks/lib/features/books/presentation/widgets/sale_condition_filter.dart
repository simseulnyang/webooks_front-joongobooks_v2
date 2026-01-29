import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// 판매 상태 필터 버튼
class SaleConditionFilter extends StatelessWidget {
  final String? selectedCondition;
  final ValueChanged<String?> onConditionChanged;

  const SaleConditionFilter({
    super.key,
    required this.selectedCondition,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: '전체',
            isSelected: selectedCondition == null || selectedCondition!.isEmpty,
            onTap: () => onConditionChanged(null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '판매중',
            isSelected: selectedCondition == 'For Sale',
            onTap: () => onConditionChanged('For Sale'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '예약중',
            isSelected: selectedCondition == 'Reserved',
            onTap: () => onConditionChanged('Reserved'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '판매완료',
            isSelected: selectedCondition == 'Sold Out',
            onTap: () => onConditionChanged('Sold Out'),
          ),
        ],
      ),
    );
  }
}

/// 개별 필터 칩
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
