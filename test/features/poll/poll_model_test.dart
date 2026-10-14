import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/poll/domain/models/poll.dart';
import 'package:f_clean_template/features/poll/domain/models/poll_response.dart';

void main() {
  test('Poll y PollResponse to y from Json con jsonEncode', () {
    final poll = Poll(
      id: '1',
      projectId: 'p1',
      authorId: 'u1',
      title: 'Titulo',
      description: 'Desc',
      closesAt: DateTime(2030, 1, 1),
      questions: [
        PollQuestion(text: 'Q1', options: ['O1', 'O2']),
      ],
    );
    
    final jsonPoll = poll.toJsonNoId();
    expect(jsonPoll['questions'], isA<String>()); // Verifica que se haya codificado como JSON String para roble
    
    final parsedPoll = Poll.fromJson({'_id': '1', ...jsonPoll});
    expect(parsedPoll.questions.first.text, 'Q1');
    expect(parsedPoll.questions.first.options.length, 2);
    
    final response = PollResponse(
      id: 'r1',
      pollId: '1',
      respondentId: 'u2',
      answers: [1],
    );
    
    final jsonResponse = response.toJsonNoId();
    expect(jsonResponse['answers'], isA<String>());
    
    final parsedResponse = PollResponse.fromJson({'_id': 'r1', ...jsonResponse});
    expect(parsedResponse.answers.first, 1);
  });
}
