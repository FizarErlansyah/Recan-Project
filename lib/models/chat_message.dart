class ChatMessage {
  const new({
    required this.isSentByUser,
    required this.text,
    required this.timestamp,
  });

  final bool isSentByUser;
  final String text;
  final DateTime timestamp;

  String get timeLabel {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
