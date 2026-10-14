import '../../domain/models/poll.dart';
import '../../domain/models/poll_response.dart';
import '../../domain/repositories/i_poll_repository.dart';
import '../datasources/i_poll_source.dart';

class PollRepository implements IPollRepository {
  PollRepository(this.source);

  final IPollSource source;

  @override
  Future<List<Poll>> getPollsForProject(String projectId) async {
    return source.getPollsForProject(projectId);
  }

  @override
  Future<Poll> createPoll(Poll poll) async {
    return source.createPoll(poll);
  }

  @override
  Future<List<PollResponse>> getResponsesForPoll(String pollId) async {
    return source.getResponsesForPoll(pollId);
  }

  @override
  Future<PollResponse> createResponse(PollResponse response) async {
    return source.createResponse(response);
  }
}
