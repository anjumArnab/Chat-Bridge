class Message {
  final String id;
  final String senderId;
  final String message;
  final DateTime timestamp;
  final String platform;

  Message({
    required this.id,
    required this.senderId,
    required this.message,
    required this.timestamp,
    required this.platform,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      platform: json['platform'],
    );
  }
}
