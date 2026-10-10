import '../models/poll.dart';
import '../models/poll_response.dart';

abstract class IPollSource {
  Future<List<Poll>> getPollsForProject(String projectId);
  Future<Poll> createPoll(Poll poll);
  
  Future<List<PollResponse>> getResponsesForPoll(String pollId);
  Future<PollResponse> createResponse(PollResponse response);
}
