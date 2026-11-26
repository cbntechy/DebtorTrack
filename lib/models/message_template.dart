class MessageTemplate {
  final String id;
  final String name;
  final String body;
  final DateTime createdAt;

  MessageTemplate({
    required this.id,
    required this.name,
    required this.body,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MessageTemplate.fromMap(Map<String, dynamic> map) {
    return MessageTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      body: map['body'] as String,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
