import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_item.dart';
import '../models/chat_message.dart';
import '../models/water_data.dart';
import '../services/chatbot_service.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatState({
    required this.messages,
    this.isTyping = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(
      messages: [
        ChatMessage(
          id: 'welcome_1',
          sender: MessageSender.assistant,
          text: 'Hello! I am your Water Quality AI Assistant. 💧\n\n'
              'Forward any critical alert or sensor reading to diagnose root causes and immediate corrective actions, or ask me any question about water quality and safety.',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  /// Send a general user message
  Future<void> sendUserMessage(String query, {WaterData? currentData}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final userMsg = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.user,
      text: trimmed,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    // Realistic processing pause
    await Future.delayed(const Duration(milliseconds: 300));

    final assistantResponse = ChatbotService.answerQuery(trimmed, currentData: currentData);

    state = state.copyWith(
      messages: [...state.messages, assistantResponse],
      isTyping: false,
    );
  }

  /// Forward a critical alert to the AI for immediate root cause & corrective measure analysis
  Future<void> forwardAlert(AlertItem alert) async {
    final userMsg = ChatMessage(
      id: 'fwd_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.user,
      text: 'Forwarded Alert: ${alert.message} [Severity: ${alert.severity.toUpperCase()}]',
      timestamp: DateTime.now(),
      forwardedContext: 'Alert #${alert.id} (${alert.parameter.isNotEmpty ? alert.parameter : "System"})',
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    await Future.delayed(const Duration(milliseconds: 400));

    final diagnosis = ChatbotService.diagnoseAlert(
      alertId: alert.id,
      severity: alert.severity,
      message: alert.message,
      deviceId: alert.deviceId,
    );

    state = state.copyWith(
      messages: [...state.messages, diagnosis],
      isTyping: false,
    );
  }

  /// Diagnose live telemetry snapshot
  Future<void> diagnoseTelemetry(WaterData data) async {
    final userMsg = ChatMessage(
      id: 'telemetry_req_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.user,
      text: 'Analyze current water telemetry readings from device ${data.deviceId}.',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    await Future.delayed(const Duration(milliseconds: 400));

    final diagnosis = ChatbotService.diagnoseTelemetry(data);

    state = state.copyWith(
      messages: [...state.messages, diagnosis],
      isTyping: false,
    );
  }

  /// Reset chat to clean welcome state
  void clearChat() {
    state = ChatState(
      messages: [
        ChatMessage(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.assistant,
          text: 'Chat history cleared. How can I assist with your water quality today?',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
