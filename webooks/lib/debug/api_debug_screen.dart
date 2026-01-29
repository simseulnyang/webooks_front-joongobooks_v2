import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/env_config.dart';
import '../core/network/dio_provider.dart';

/// API 연결 테스트 화면
/// 개발 중 디버깅 용도로만 사용
class ApiDebugScreen extends ConsumerWidget {
  const ApiDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dio = ref.watch(dioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('API 디버그')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('환경 설정', [
            _buildItem('API Base URL', EnvConfig.apiBaseUrl),
            _buildItem('WS Base URL', EnvConfig.wsBaseUrl),
            _buildItem(
              'Kakao 설정',
              EnvConfig.isKakaoConfigured ? '✅ 완료' : '❌ 미완료',
            ),
            _buildItem(
              'Google 설정',
              EnvConfig.isGoogleConfigured ? '✅ 완료' : '❌ 미완료',
            ),
          ]),

          const Divider(height: 32),

          _buildSection('Dio 설정', [
            _buildItem('Base URL', dio.options.baseUrl),
            _buildItem(
              'Connect Timeout',
              '${dio.options.connectTimeout?.inSeconds}초',
            ),
            _buildItem(
              'Receive Timeout',
              '${dio.options.receiveTimeout?.inSeconds}초',
            ),
          ]),

          const Divider(height: 32),

          ElevatedButton.icon(
            onPressed: () => _testConnection(context, dio),
            icon: const Icon(Icons.network_check),
            label: const Text('API 연결 테스트'),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () => _testBookDetail(context, dio),
            icon: const Icon(Icons.book),
            label: const Text('책 상세 조회 테스트 (ID: 1)'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection(BuildContext context, dio) async {
    try {
      final response = await dio.get('books/');

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ 연결 성공'),
            content: Text(
              '응답 코드: ${response.statusCode}\n'
              '책 개수: ${response.data['count']}개',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ 연결 실패'),
            content: Text('오류: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _testBookDetail(BuildContext context, dio) async {
    try {
      final response = await dio.get('books/detail/1/');

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ 상세 조회 성공'),
            content: SingleChildScrollView(
              child: Text(
                '책 제목: ${response.data['title']}\n'
                '저자: ${response.data['author']}\n'
                '가격: ${response.data['selling_price']}원\n\n'
                '전체 응답:\n${response.data}',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ 상세 조회 실패'),
            content: Text(
              '오류: $e\n\n'
              '예상 URL: ${dio.options.baseUrl}/books/detail/1/',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }
}
