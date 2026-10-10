import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart';
import 'package:f_clean_template/features/poll/data/datasources/remote/roble_poll_source.dart';
import 'package:f_clean_template/features/poll/domain/models/poll.dart';

class FakeRobleDatabase extends RobleApiDataBase {
  FakeRobleDatabase()
      : super(
          config: RobleApiConfig.fromContract(
            baseUrl: 'https://roble.test-openlab.uninorte.edu.co',
            contractId: 'proyecto_test_12345678',
          ),
        );

  final List<Map<String, dynamic>> polls = [];
  final List<Map<String, dynamic>> responses = [];

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
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
    late FakeRobleDatabase fakeRoble;
    late RoblePollSource source;

    setUp(() {
      fakeRoble = FakeRobleDatabase();
      source = RoblePollSource(fakeRoble);
    });

    test('getPollsForProject lee desde roble', () async {
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
      expect(list.length, 1);
      expect(list.first.title, 'Test Poll');
      expect(list.first.questions.length, 1);
      
      final empty = await source.getPollsForProject('proj2');
      expect(empty.isEmpty, true);
    });

    test('createPoll guarda como texto los arreglos JSON', () async {
      final p = Poll(
        projectId: 'proj1',
        authorId: 'auth1',
        title: 'New Poll',
        description: 'Desc',
        questions: [PollQuestion(text: 'Q1', options: ['A', 'B'])],
        closesAt: DateTime(2050, 1, 1),
      );
      
      final created = await source.createPoll(p);
      expect(created.id, isNotNull);
      expect(fakeRoble.polls.first['questions'], isA<String>());
    });
  });
}
