class Question {
  final String id;
  final String text;
  final QuestionType type;

  Question({
    required this.id,
    required this.text,
    required this.type,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      type: QuestionType.fromString(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
    };
  }
}

enum QuestionType {
  text,
  progress,
  check;

  static QuestionType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return QuestionType.text;
      case 'progress':
        return QuestionType.progress;
      case 'check':
        return QuestionType.check;
      default:
        return QuestionType.text;
    }
  }
}
