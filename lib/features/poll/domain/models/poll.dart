import 'dart:convert';

class PollQuestion {
  PollQuestion({
    required this.text,
    required this.options,
  });

  final String text;
  final List<String> options;

  factory PollQuestion.fromJson(Map<String, dynamic> json) {
    return PollQuestion(
      text: json['text']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'options': options,
      };
}

class Poll {
  Poll({
    this.id,
    required this.projectId,
    required this.authorId,
    required this.title,
    required this.description,
    required this.questions,
    required this.closesAt,
    this.audienceProgram,
  });

  final String? id;
  final String projectId;
  final String authorId;
  final String title;
  final String description;
  final List<PollQuestion> questions;
  final DateTime closesAt;
  final String? audienceProgram;

  bool get isActive => DateTime.now().isBefore(closesAt);

  factory Poll.fromJson(Map<String, dynamic> json) {
    List<PollQuestion> parsedQuestions = [];
    final questionsRaw = json['questions'];
    
    if (questionsRaw is List) {
      parsedQuestions = questionsRaw.map((q) => PollQuestion.fromJson(q as Map<String, dynamic>)).toList();
    } else if (questionsRaw is String) {
      try {
        final decoded = jsonDecode(questionsRaw);
        if (decoded is List) {
          parsedQuestions = decoded.map((q) => PollQuestion.fromJson(q as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    return Poll(
      id: (json['_id'] ?? json['id'])?.toString(),
      projectId: json['project_id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      questions: parsedQuestions,
      closesAt: DateTime.parse(json['closes_at']?.toString() ?? DateTime.now().toIso8601String()),
      audienceProgram: json['audience_program']?.toString().isEmpty == true ? null : json['audience_program']?.toString(),
    );
  }

  Map<String, dynamic> toJsonNoId() => {
        'project_id': projectId,
        'author_id': authorId,
        'title': title,
        'description': description,
        'questions': jsonEncode(questions.map((q) => q.toJson()).toList()),
        'closes_at': closesAt.toIso8601String(),
        'audience_program': audienceProgram ?? '',
      };
}
