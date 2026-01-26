import 'package:flutter/material.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// 소셜 로그인 버튼 위젯
class SocialLoginButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: backgroundColor == Colors.white
                  ? Colors.grey.shade300
                  : backgroundColor,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
