import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';

/// 프로필 수정 화면
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 현재 사용자 정보로 초기화
    final user = ref.read(authProvider).user;
    _usernameController = TextEditingController(text: user?.username ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // 로그인 안 되어 있으면 에러
    if (!authState.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('프로필 수정')),
        body: const Center(child: Text('로그인이 필요합니다.')),
      );
    }

    final user = authState.user!;

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 수정')),
      body: _isLoading
          ? const AppLoading(message: '프로필을 수정하는 중...')
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // 프로필 이미지
                  Center(
                    child: Stack(
                      children: [
                        user.profileImage.isNotEmpty
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(
                                  user.profileImage,
                                ),
                              )
                            : const CircleAvatar(
                                radius: 60,
                                child: Icon(Icons.person, size: 60),
                              ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                // TODO: 이미지 선택
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('이미지 변경 기능은 추후 구현 예정입니다.'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 닉네임
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: '닉네임',
                      hintText: '닉네임을 입력하세요 (2-20자)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '닉네임을 입력해주세요';
                      }
                      if (value.length < 2) {
                        return '닉네임은 최소 2자 이상이어야 합니다';
                      }
                      if (value.length > 20) {
                        return '닉네임은 최대 20자 이하여야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 이메일 (읽기 전용)
                  TextFormField(
                    initialValue: user.email,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 수정 버튼
                  AppButton(
                    text: '수정하기',
                    onPressed: _handleSubmit,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // TODO: 프로필 수정 API 연결
      setState(() => _isLoading = true);

      // 임시: 2초 후 완료
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로필이 수정되었습니다.'),
              backgroundColor: AppColors.primary,
            ),
          );

          Navigator.pop(context);
        }
      });
    }
  }
}
