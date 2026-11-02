import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiServiceException implements Exception {
  const AiServiceException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AiService {
  AiService({
    http.Client? client,
    FlutterSecureStorage? storage,
    String? fallbackApiKey,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage(),
        _fallbackApiKey = fallbackApiKey;

  final http.Client _client;
  final FlutterSecureStorage _storage;
  final String? _fallbackApiKey;

  static const _storageKey = 'ai_api_key';
  static const _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static const _systemInstruction =
      'Kamu adalah Campus AI Assistant untuk mahasiswa JTI Politeknik Negeri Malang (Polinema). '
      'Bantulah mahasiswa menjawab pertanyaan seputar perkuliahan, jadwal, materi pemrograman mobile, tips belajar, '
      'dan fasilitas kampus secara ramah, ringkas, dan jelas dalam Bahasa Indonesia.';

  Future<String?> getApiKey() async {
    if (_fallbackApiKey != null && _fallbackApiKey.isNotEmpty) {
      return _fallbackApiKey;
    }
    try {
      final storedKey = await _storage.read(key: _storageKey);
      if (storedKey != null && storedKey.isNotEmpty) return storedKey;
    } catch (_) {
      // Platform channel unavailable in headless tests
    }
    return null;
  }

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: _storageKey, value: key);
  }

  Future<String> ask(String question) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const AiServiceException(
        'Kunci API Gemini belum dikonfigurasi. Silakan atur di pengaturan.',
        statusCode: 401,
      );
    }

    final url = Uri.parse('$_apiUrl?key=$apiKey');
    final payload = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '[$_systemInstruction]\nPertanyaan: $question'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 500,
      }
    });

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return (parts[0]['text'] as String? ?? '').trim();
          }
        }
        return 'Maaf, AI tidak memberikan respons yang dapat ditampilkan.';
      } else if (response.statusCode == 400) {
        throw const AiServiceException('Format permintaan tidak valid.', statusCode: 400);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AiServiceException('Kunci API Gemini tidak valid atau kedaluwarsa.', statusCode: 403);
      } else if (response.statusCode == 429) {
        throw const AiServiceException('Batas kuota harian AI tercapai. Gunakan mode fallback.', statusCode: 429);
      } else {
        throw AiServiceException('Layanan AI mengalami kendala (HTTP ${response.statusCode}).', statusCode: response.statusCode);
      }
    } on http.ClientException {
      throw const AiServiceException('Tidak ada koneksi internet. Mengalihkan ke mode lokal.');
    }
  }
}
