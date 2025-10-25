class Answer {
  final String questionId;
  final String answer;
  final DateTime timestamp;

  Answer({
    required this.questionId,
    required this.answer,
    required this.timestamp,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionId: json['questionId'] as String,
      answer: json['answer'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
