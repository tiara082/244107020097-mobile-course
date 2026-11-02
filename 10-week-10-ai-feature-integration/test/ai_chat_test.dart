import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:campus_ai_assistant/ai/ai_service.dart';
import 'package:campus_ai_assistant/features/chat/domain/services/privacy_sanitizer.dart';
import 'package:campus_ai_assistant/features/chat/presentation/pages/chat_screen.dart';
import 'package:campus_ai_assistant/features/chat/presentation/providers/chat_provider.dart';

void main() {
  group('PrivacySanitizer Unit Tests', () {
    const sanitizer = PrivacySanitizer();

    test('scrubs NIK, NIM, phone numbers, and emails', () {
      const rawText =
          'Halo nama saya Tiara NIM 244107020097 NIK 3507112233445566 '
          'no hp 081234567890 dan email tiara@polinema.ac.id';

      final sanitized = sanitizer.sanitize(rawText);

      expect(sanitized.contains('244107020097'), isFalse);
      expect(sanitized.contains('[REDACTED_NIM]'), isTrue);

      expect(sanitized.contains('3507112233445566'), isFalse);
      expect(sanitized.contains('[REDACTED_NIK]'), isTrue);

      expect(sanitized.contains('081234567890'), isFalse);
      expect(sanitized.contains('[REDACTED_PHONE]'), isTrue);

      expect(sanitized.contains('tiara@polinema.ac.id'), isFalse);
      expect(sanitized.contains('[REDACTED_EMAIL]'), isTrue);
    });
  });

  group('AiService Unit Tests with Mock Client', () {
    test('throws 401 when API key is missing', () async {
      final service = AiService(
        client: http.Client(),
        fallbackApiKey: null,
      );

      await expectLater(
        service.ask('Halo'),
        throwsA(
          isA<AiServiceException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('parses Gemini API 200 response successfully', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['key'], 'dummy_key');
        final responseBody = jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Jadwal kuliah Mobile berlangsung setiap hari Rabu.'}
                ]
              }
            }
          ]
        });
        return http.Response(responseBody, 200, headers: {'content-type': 'application/json'});
      });

      final service = AiService(
        client: mockClient,
        fallbackApiKey: 'dummy_key',
      );

      final reply = await service.ask('Kapan jadwal kuliah mobile?');
      expect(reply, 'Jadwal kuliah Mobile berlangsung setiap hari Rabu.');
    });

    test('throws 429 when quota limit is exceeded', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'error': 'Quota exceeded'}), 429);
      });

      final service = AiService(
        client: mockClient,
        fallbackApiKey: 'dummy_key',
      );

      await expectLater(
        service.ask('Pertanyaan'),
        throwsA(
          isA<AiServiceException>().having((e) => e.statusCode, 'statusCode', 429),
        ),
      );
    });
  });

  group('ChatNotifier & Fallback Logic Tests', () {
    test('triggers offline local fallback on network error', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Connection failed');
      });

      final service = AiService(client: mockClient, fallbackApiKey: 'dummy_key');
      final notifier = ChatNotifier(
        aiService: service,
        sanitizer: const PrivacySanitizer(),
      );

      await notifier.sendMessage('Kapan jadwal kuliah saya?');

      expect(notifier.state.messages.length, 3);
      final lastMsg = notifier.state.messages.last;
      expect(lastMsg.isUser, isFalse);
      expect(lastMsg.isFallback, isTrue);
      expect(lastMsg.text.contains('[Mode Offline / Fallback Lokal]'), isTrue);
      expect(lastMsg.text.contains('Jadwal Kuliah Mobile'), isTrue);
    });
  });

  group('ChatScreen Widget Tests', () {
    testWidgets('renders header, suggestions, and initial welcome bubble', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ChatScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Campus AI Assistant'), findsOneWidget);
      expect(find.text('Jadwal Kuliah Mobile'), findsOneWidget);
      expect(find.text('Lokasi Perpustakaan'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
