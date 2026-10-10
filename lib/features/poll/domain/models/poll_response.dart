import 'dart:convert';

class PollResponse {
  PollResponse({
    this.id,
    required this.pollId,
    required this.respondentId,
    required this.answers,
    this.comment,
  });

  final String? id;
  final String pollId;
  final String respondentId;
  /// Lista de índices elegidos, uno por pregunta.
  final List<int> answers;
  final String? comment;

  factory PollResponse.fromJson(Map<String, dynamic> json) {
    List<int> parsedAnswers = [];
    final answersRaw = json['answers'];
    
    if (answersRaw is List) {
      parsedAnswers = answersRaw.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    } else if (answersRaw is String) {
      try {
        final decoded = jsonDecode(answersRaw);
        if (decoded is List) {
          parsedAnswers = decoded.map((e) => int.tryParse(e.toString()) ?? 0).toList();
        }
      } catch (_) {}
    }

    return PollResponse(
      id: (json['_id'] ?? json['id'])?.toString(),
      pollId: json['poll_id']?.toString() ?? '',
      respondentId: json['respondent_id']?.toString() ?? '',
      answers: parsedAnswers,
      comment: json['comment']?.toString().isEmpty == true ? null : json['comment']?.toString(),
    );
  }

  Map<String, dynamic> toJsonNoId() => {
        'poll_id': pollId,
        'respondent_id': respondentId,
        'answers': jsonEncode(answers),
        'comment': comment ?? '',
      };
}
