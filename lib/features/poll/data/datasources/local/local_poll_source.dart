import '../../../domain/models/poll.dart';
import '../../../domain/models/poll_response.dart';
import '../i_poll_source.dart';

class LocalPollSource implements IPollSource {
  final List<Poll> _polls = [];
  final List<PollResponse> _responses = [];
  int _nextPollId = 1;
  int _nextResponseId = 1;

  @override
  Future<List<Poll>> getPollsForProject(String projectId) async {
    return _polls.where((p) => p.projectId == projectId).toList();
  }

  @override
  Future<Poll> createPoll(Poll poll) async {
    final p = Poll(
      id: 'p${_nextPollId++}',
      projectId: poll.projectId,
      authorId: poll.authorId,
      title: poll.title,
      description: poll.description,
      questions: poll.questions,
      closesAt: poll.closesAt,
      audienceProgram: poll.audienceProgram,
    );
    _polls.add(p);
    return p;
  }

  @override
  Future<List<PollResponse>> getResponsesForPoll(String pollId) async {
    return _responses.where((r) => r.pollId == pollId).toList();
  }

  @override
  Future<PollResponse> createResponse(PollResponse response) async {
    final r = PollResponse(
      id: 'r${_nextResponseId++}',
      pollId: response.pollId,
      respondentId: response.respondentId,
      answers: response.answers,
      comment: response.comment,
    );
    _responses.add(r);
    return r;
  }
}
