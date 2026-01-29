import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/config/env_config.dart';

/// 긴급 테스트 화면
class EmergencyTestScreen extends ConsumerStatefulWidget {
  const EmergencyTestScreen({super.key});

  @override
  ConsumerState<EmergencyTestScreen> createState() =>
      _EmergencyTestScreenState();
}

class _EmergencyTestScreenState extends ConsumerState<EmergencyTestScreen> {
  String _result = '테스트를 시작하려면 버튼을 누르세요';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('긴급 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 환경 변수 표시
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '환경 설정:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText('API_BASE_URL: ${EnvConfig.apiBaseUrl}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 결과 표시
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SelectableText(_result),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 테스트 버튼들
            ElevatedButton(
              onPressed: _isLoading ? null : _testBookList,
              child: const Text('1. 책 목록 조회 테스트'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading ? null : _testBookDetail,
              child: const Text('2. 책 상세 조회 테스트 (ID: 1)'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading ? null : _testDirect,
              child: const Text('3. 직접 URL 테스트'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testBookList() async {
    setState(() {
      _isLoading = true;
      _result = '책 목록 조회 중...';
    });

    try {
      final dio = Dio();
      final url = '${EnvConfig.apiBaseUrl}books/';

      print('🔍 요청 URL: $url');

      final response = await dio.get(url);

      setState(() {
        _result =
            '''
✅ 책 목록 조회 성공!

상태 코드: ${response.statusCode}
책 개수: ${response.data['count']}개

첫 번째 책:
${response.data['results'][0]}
''';
      });
    } catch (e) {
      setState(() {
        _result =
            '''
❌ 책 목록 조회 실패!

오류: $e
''';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testBookDetail() async {
    setState(() {
      _isLoading = true;
      _result = '책 상세 조회 중...';
    });

    try {
      final dio = Dio();
      final url = '${EnvConfig.apiBaseUrl}books/detail/1/';

      print('🔍 요청 URL: $url');

      final response = await dio.get(url);

      setState(() {
        _result =
            '''
✅ 책 상세 조회 성공!

상태 코드: ${response.statusCode}

책 정보:
제목: ${response.data['title']}
저자: ${response.data['author']}
가격: ${response.data['selling_price']}원

전체 응답:
${response.data}
''';
      });
    } catch (e) {
      if (e is DioException) {
        setState(() {
          _result =
              '''
❌ 책 상세 조회 실패!

요청 URL: ${e.requestOptions.uri}
상태 코드: ${e.response?.statusCode}
응답 데이터: ${e.response?.data}
오류 메시지: ${e.message}
''';
        });
      } else {
        setState(() {
          _result = '❌ 오류: $e';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testDirect() async {
    setState(() {
      _isLoading = true;
      _result = '직접 URL 테스트 중...';
    });

    try {
      final dio = Dio();

      // 여러 URL 패턴 시도
      final urls = [
        'http://10.0.2.2:8000/api/books/detail/1/',
        'http://localhost:8000/api/books/detail/1/',
        '${EnvConfig.apiBaseUrl}/books/detail/1/',
      ];

      String results = '';

      for (final url in urls) {
        try {
          print('🔍 시도 중: $url');
          final response = await dio.get(url);
          results += '✅ $url - 성공 (${response.statusCode})\n\n';
        } catch (e) {
          if (e is DioException) {
            results +=
                '❌ $url - 실패 (${e.response?.statusCode})\n${e.message}\n\n';
          } else {
            results += '❌ $url - 실패\n$e\n\n';
          }
        }
      }

      setState(() {
        _result = results;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
