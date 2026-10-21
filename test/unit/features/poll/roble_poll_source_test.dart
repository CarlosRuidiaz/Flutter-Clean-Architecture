import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart';
import 'package:f_clean_template/features/poll/data/datasources/remote/roble_poll_source.dart';
import 'package:f_clean_template/features/poll/domain/models/poll.dart';
import 'package:f_clean_template/features/poll/domain/models/poll_response.dart';

class FakeRobleDatabaseForPoll extends RobleApiDataBase {
  FakeRobleDatabaseForPoll()
      : super(
          config: RobleApiConfig.fromContract(
            baseUrl: 'https://roble.test-openlab.uninorte.edu.co',
            contractId: 'proyecto_test_12345678',
          ),
        );

  final List<Map<String, dynamic>> polls = [];
  final List<Map<String, dynamic>> responses = [];

  String? lastReadTable;
  Map<String, dynamic>? lastFilters;
  String? lastCreateTable;
  Map<String, dynamic>? lastCreateData;
  bool shouldThrowOnRead = false;

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
    lastReadTable = tableName;
    lastFilters = filters;
    if (shouldThrowOnRead) {
      throw Exception('Fallo de red en Roble Poll');
    }
    if (tableName == 'polls') {
      if (filters != null && filters.containsKey('project_id')) {
        return polls.where((p) => p['project_id'] == filters['project_id']).toList();
      }
      return polls;
    }
    if (tableName == 'poll_responses') {
      if (filters != null && filters.containsKey('poll_id')) {
        return responses.where((r) => r['poll_id'] == filters['poll_id']).toList();
      }
      return responses;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> create(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    lastCreateTable = tableName;
    lastCreateData = data;
    if (tableName == 'polls') {
      final record = Map<String, dynamic>.from(data);
      record['_id'] = 'poll_${polls.length + 1}';
      polls.add(record);
      return record;
    }
    if (tableName == 'poll_responses') {
      final record = Map<String, dynamic>.from(data);
      record['_id'] = 'resp_${responses.length + 1}';
      responses.add(record);
      return record;
    }
    return {};
  }
}

void main() {
  group('RoblePollSource', () {
    late FakeRobleDatabaseForPoll fakeRoble;
    late RoblePollSource source;

    setUp(() {
      fakeRoble = FakeRobleDatabaseForPoll();
      source = RoblePollSource(fakeRoble);
    });

    test('getPollsForProject pide tabla polls con filtro project_id', () async {
      fakeRoble.polls.add({
        '_id': 'p1',
        'project_id': 'proj1',
        'author_id': 'auth1',
        'title': 'Test Poll',
        'description': '',
        'questions': '[{"text":"Q1","options":["1","2"]}]',
        'closes_at': DateTime.now().toIso8601String(),
        'audience_program': '',
      });

      final list = await source.getPollsForProject('proj1');
      expect(fakeRoble.lastReadTable, 'polls');
      expect(fakeRoble.lastFilters, {'project_id': 'proj1'});
      expect(list.length, 1);
      expect(list.first.title, 'Test Poll');
      expect(list.first.questions.length, 1);

      final empty = await source.getPollsForProject('proj_inexistente');
      expect(empty.isEmpty, true);
    });

    test('getPollsForProject propaga error cuando Roble falla', () async {
      fakeRoble.shouldThrowOnRead = true;
      expect(() => source.getPollsForProject('proj1'), throwsA(isA<Exception>()));
    });

    test('createPoll guarda como texto los arreglos JSON y asigna _id', () async {
      final p = Poll(
        projectId: 'proj1',
        authorId: 'auth1',
        title: 'New Poll',
        description: 'Desc',
        questions: [PollQuestion(text: 'Q1', options: ['A', 'B'])],
        closesAt: DateTime(2050, 1, 1),
      );

      final created = await source.createPoll(p);
      expect(fakeRoble.lastCreateTable, 'polls');
      expect(fakeRoble.lastCreateData?['questions'], isA<String>());
      expect(created.id, isNotNull);
      expect(fakeRoble.polls.length, 1);
    });

    test('getResponsesForPoll pide tabla poll_responses con filtro poll_id', () async {
      fakeRoble.responses.add({
        '_id': 'r1',
        'poll_id': 'poll_1',
        'respondent_id': 'u1',
        'answers': '[0, 1]',
        'comment': 'OK',
      });

      final list = await source.getResponsesForPoll('poll_1');
      expect(fakeRoble.lastReadTable, 'poll_responses');
      expect(fakeRoble.lastFilters, {'poll_id': 'poll_1'});
      expect(list.length, 1);
      expect(list.first.id, 'r1');
      expect(list.first.answers, [0, 1]);
    });

    test('getResponsesForPoll propaga error cuando Roble falla', () async {
      fakeRoble.shouldThrowOnRead = true;
      expect(() => source.getResponsesForPoll('poll_1'), throwsA(isA<Exception>()));
    });

    test('createResponse guarda answers como texto JSON y asigna _id', () async {
      final response = PollResponse(
        pollId: 'poll_1',
        respondentId: 'u2',
        answers: const [1, 2],
        comment: 'Buen disenio',
      );

      final created = await source.createResponse(response);
      expect(fakeRoble.lastCreateTable, 'poll_responses');
      expect(fakeRoble.lastCreateData?['answers'], isA<String>());
      expect(created.id, isNotNull);
      expect(fakeRoble.responses.length, 1);
    });
  });
}
