import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

import '../../../domain/models/poll.dart';
import '../../../domain/models/poll_response.dart';
import '../i_poll_source.dart';

class RoblePollSource with UiLoggy implements IPollSource {
  RoblePollSource(this.roble);

  final RobleApiDataBase roble;

  @override
  Future<List<Poll>> getPollsForProject(String projectId) async {
    loggy.debug('RoblePollSource: buscando encuestas del proyecto $projectId');
    final records = await roble.read('polls', filters: {'project_id': projectId});
    return records.map(Poll.fromJson).toList();
  }

  @override
  Future<Poll> createPoll(Poll poll) async {
    loggy.debug('RoblePollSource: insertando en polls');
    final record = await roble.create('polls', poll.toJsonNoId());
    return Poll.fromJson(record);
  }

  @override
  Future<List<PollResponse>> getResponsesForPoll(String pollId) async {
    loggy.debug('RoblePollSource: buscando respuestas de encuesta $pollId');
    final records = await roble.read('poll_responses', filters: {'poll_id': pollId});
    return records.map(PollResponse.fromJson).toList();
  }

  @override
  Future<PollResponse> createResponse(PollResponse response) async {
    loggy.debug('RoblePollSource: insertando en poll_responses');
    final record = await roble.create('poll_responses', response.toJsonNoId());
    return PollResponse.fromJson(record);
  }
}
