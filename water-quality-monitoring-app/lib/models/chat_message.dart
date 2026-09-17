enum MessageSender {
  user,
  assistant,
  system,
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final List<String>? possibleCauses;
  final List<String>? correctiveMeasures;
  final String? forwardedContext;
  final bool isDiagnosis;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.possibleCauses,
    this.correctiveMeasures,
    this.forwardedContext,
    this.isDiagnosis = false,
  });

  bool get isUser => sender == MessageSender.user;
  bool get isAssistant => sender == MessageSender.assistant;
  bool get isSystem => sender == MessageSender.system;
}
