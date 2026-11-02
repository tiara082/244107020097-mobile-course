import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campus_ai_assistant/ai/ai_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/services/privacy_sanitizer.dart';

class ChatState {
  const ChatState({
    required this.messages,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final aiServiceProvider = Provider<AiService>((ref) => AiService());

final privacySanitizerProvider = Provider<PrivacySanitizer>((ref) => const PrivacySanitizer());

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final sanitizer = ref.watch(privacySanitizerProvider);
  return ChatNotifier(aiService: aiService, sanitizer: sanitizer);
});

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier({
    required AiService aiService,
    required PrivacySanitizer sanitizer,
  })  : _aiService = aiService,
        _sanitizer = sanitizer,
        super(ChatState(
          messages: [
            ChatMessage(
              id: 'init_welcome',
              text: 'Halo! Saya Campus AI Assistant Polinema. '
                  'Ada yang bisa saya bantu terkait jadwal, materi kuliah mobile, atau info akademik kampus?',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
        ));

  final AiService _aiService;
  final PrivacySanitizer _sanitizer;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final sanitizedText = _sanitizer.sanitize(trimmed);
    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: sanitizedText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      errorMessage: null,
    );

    try {
      final aiResponse = await _aiService.ask(sanitizedText);
      final aiMsg = ChatMessage(
        id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );
    } catch (error) {
      final fallbackText = _generateLocalFallback(sanitizedText, error.toString());
      final fallbackMsg = ChatMessage(
        id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        text: fallbackText,
        isUser: false,
        timestamp: DateTime.now(),
        isFallback: true,
      );

      state = state.copyWith(
        messages: [...state.messages, fallbackMsg],
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  String _generateLocalFallback(String query, String errorDetail) {
    final lower = query.toLowerCase();
    if (lower.contains('jadwal') || lower.contains('kuliah')) {
      return '[Mode Offline / Fallback Lokal]\n'
          'Jadwal Kuliah Mobile: Kelas TI-3I dilaksanakan setiap hari Rabu pukul 13.00 di Ruang A2 Gedung Sipil Polinema.';
    }
    if (lower.contains('krs') || lower.contains('siakad')) {
      return '[Mode Offline / Fallback Lokal]\n'
          'Info KRS: Kartu Rencana Studi dapat divalidasi melalui SIAKAD Polinema dengan persetujuan Dosen Pembimbing Akademik.';
    }
    if (lower.contains('perpustakaan') || lower.contains('buku')) {
      return '[Mode Offline / Fallback Lokal]\n'
          'Info Perpustakaan: Perpustakaan Pusat Polinema buka Senin-Jumat pukul 07.30 - 16.00 WIB.';
    }
    return '[Mode Offline / Fallback Lokal]\n'
        'Layanan AI cloud sedang tidak tersedia ($errorDetail). '
        'Pertanyaan Anda telah dicatat dalam basis data lokal.';
  }

  void clearChat() {
    state = ChatState(
      messages: [
        ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: 'Halo kembali! Percakapan telah dibersihkan. Apa yang ingin Anda tanyakan?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}
