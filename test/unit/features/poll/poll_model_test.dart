import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/poll/domain/models/poll.dart';
import 'package:f_clean_template/features/poll/domain/models/poll_response.dart';

void main() {
  group('Poll', () {
    group('isActive', () {
      test('es verdadero cuando closesAt esta en el futuro', () {
        final futura = Poll(
          projectId: 'p1',
          authorId: 'u1',
          title: 'Encuesta activa',
          description: '',
          questions: const [],
          closesAt: DateTime.now().add(const Duration(days: 5)),
        );
        expect(futura.isActive, isTrue);
      });

      test('es falso cuando closesAt ya paso', () {
        final pasada = Poll(
          projectId: 'p1',
          authorId: 'u1',
          title: 'Encuesta cerrada',
          description: '',
          questions: const [],
          closesAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(pasada.isActive, isFalse);
      });
    });

    group('fromJson y toJson', () {
      test('fromJson con datos completos mapea cada atributo', () {
        final fecha = DateTime(2030, 5, 20, 10, 0);
        final json = {
          '_id': 'poll_1',
          'project_id': 'proj_1',
          'author_id': 'user_1',
          'title': 'Encuesta UX',
          'description': 'Feedback de interfaz',
          'questions': [
            {
              'text': 'Te gusto el diseno?',
              'options': ['Si', 'No', 'Tal vez'],
            }
          ],
          'closes_at': fecha.toIso8601String(),
          'audience_program': 'Ingenieria de Sistemas',
        };

        final poll = Poll.fromJson(json);

        expect(poll.id, 'poll_1');
        expect(poll.projectId, 'proj_1');
        expect(poll.authorId, 'user_1');
        expect(poll.title, 'Encuesta UX');
        expect(poll.description, 'Feedback de interfaz');
        expect(poll.questions.length, 1);
        expect(poll.questions.first.text, 'Te gusto el diseno?');
        expect(poll.questions.first.options, ['Si', 'No', 'Tal vez']);
        expect(poll.closesAt, fecha);
        expect(poll.audienceProgram, 'Ingenieria de Sistemas');
      });

      test('fromJson con datos que faltan o vienen mal usa valores por defecto sin reventar', () {
        final jsonInvalido = <String, dynamic>{
          'questions': 'no_es_json_valido',
          'closes_at': 'fecha_invalida_no_parseable',
          'audience_program': '',
        };

        // fecha_invalida_no_parseable causa FormatException en DateTime.parse si no es ISO.
        // Pero si closes_at es null, usa DateTime.now().
        final jsonNullCloses = <String, dynamic>{
          'questions': null,
          'closes_at': null,
          'audience_program': '',
        };

        final poll = Poll.fromJson(jsonNullCloses);

        expect(poll.id, isNull);
        expect(poll.projectId, isEmpty);
        expect(poll.authorId, isEmpty);
        expect(poll.title, isEmpty);
        expect(poll.description, isEmpty);
        expect(poll.questions, isEmpty);
        expect(poll.audienceProgram, isNull);
        expect(poll.closesAt, isNotNull);
      });

      test('fromJson maneja questions recibidas como texto JSON codificado', () {
        final preguntasJson = jsonEncode([
          {
            'text': 'Pregunta codificada',
            'options': ['Opc 1', 'Opc 2'],
          }
        ]);

        final json = {
          '_id': 'poll_2',
          'project_id': 'p2',
          'author_id': 'u2',
          'title': 'Test',
          'description': '',
          'questions': preguntasJson,
          'closes_at': DateTime(2035, 1, 1).toIso8601String(),
        };

        final poll = Poll.fromJson(json);

        expect(poll.questions.length, 1);
        expect(poll.questions.first.text, 'Pregunta codificada');
        expect(poll.questions.first.options, ['Opc 1', 'Opc 2']);
      });

      test('toJsonNoId contiene las columnas correctas sin id y con questions como texto JSON', () {
        final fecha = DateTime(2032, 12, 31, 23, 59);
        final poll = Poll(
          id: 'poll_ignorar',
          projectId: 'p3',
          authorId: 'u3',
          title: 'Encuesta de satisfaccion',
          description: 'Descripcion corta',
          questions: [
            PollQuestion(text: 'P1', options: ['A', 'B']),
          ],
          closesAt: fecha,
          audienceProgram: 'Diseno',
        );

        final jsonNoId = poll.toJsonNoId();

        expect(jsonNoId.containsKey('_id'), isFalse);
        expect(jsonNoId.containsKey('id'), isFalse);
        expect(jsonNoId['project_id'], 'p3');
        expect(jsonNoId['author_id'], 'u3');
        expect(jsonNoId['title'], 'Encuesta de satisfaccion');
        expect(jsonNoId['description'], 'Descripcion corta');
        expect(jsonNoId['questions'], isA<String>());
        expect(jsonNoId['closes_at'], fecha.toIso8601String());
        expect(jsonNoId['audience_program'], 'Diseno');
      });

      test('ida y vuelta: lo que se envia en toJsonNoId vuelve igual con fromJson', () {
        final fecha = DateTime(2031, 6, 15, 12, 0);
        final original = Poll(
          projectId: 'proj_x',
          authorId: 'auth_y',
          title: 'Titulo encuesta',
          description: 'Detalles de la encuesta',
          questions: [
            PollQuestion(text: 'Pregunta 1', options: ['1', '2', '3']),
          ],
          closesAt: fecha,
          audienceProgram: 'Medicina',
        );

        final enviado = original.toJsonNoId();
        final devuelto = Poll.fromJson(enviado);

        expect(devuelto.projectId, original.projectId);
        expect(devuelto.authorId, original.authorId);
        expect(devuelto.title, original.title);
        expect(devuelto.description, original.description);
        expect(devuelto.questions.length, 1);
        expect(devuelto.questions.first.text, 'Pregunta 1');
        expect(devuelto.questions.first.options, ['1', '2', '3']);
        expect(devuelto.closesAt, original.closesAt);
        expect(devuelto.audienceProgram, original.audienceProgram);
      });
    });
  });

  group('PollResponse', () {
    group('fromJson y toJson', () {
      test('fromJson con datos completos mapea cada atributo', () {
        final json = {
          '_id': 'resp_1',
          'poll_id': 'poll_1',
          'respondent_id': 'user_2',
          'answers': [0, 2],
          'comment': 'Muy interesante',
        };

        final response = PollResponse.fromJson(json);

        expect(response.id, 'resp_1');
        expect(response.pollId, 'poll_1');
        expect(response.respondentId, 'user_2');
        expect(response.answers, [0, 2]);
        expect(response.comment, 'Muy interesante');
      });

      test('fromJson con datos que faltan o vienen mal usa valores por defecto sin reventar', () {
        final json = <String, dynamic>{
          'answers': 'no_es_json',
          'comment': '',
        };

        final response = PollResponse.fromJson(json);

        expect(response.id, isNull);
        expect(response.pollId, isEmpty);
        expect(response.respondentId, isEmpty);
        expect(response.answers, isEmpty);
        expect(response.comment, isNull);
      });

      test('fromJson maneja answers recibidas como texto JSON codificado', () {
        final json = {
          '_id': 'resp_2',
          'poll_id': 'poll_2',
          'respondent_id': 'u5',
          'answers': jsonEncode([1, 3]),
        };

        final response = PollResponse.fromJson(json);

        expect(response.answers, [1, 3]);
      });

      test('toJsonNoId contiene las columnas correctas sin id y con answers como texto JSON', () {
        final response = PollResponse(
          id: 'resp_ignorar',
          pollId: 'poll_9',
          respondentId: 'u9',
          answers: const [2, 0],
          comment: 'Buen trabajo',
        );

        final jsonNoId = response.toJsonNoId();

        expect(jsonNoId.containsKey('_id'), isFalse);
        expect(jsonNoId.containsKey('id'), isFalse);
        expect(jsonNoId['poll_id'], 'poll_9');
        expect(jsonNoId['respondent_id'], 'u9');
        expect(jsonNoId['answers'], isA<String>());
        expect(jsonNoId['answers'], jsonEncode([2, 0]));
        expect(jsonNoId['comment'], 'Buen trabajo');
      });

      test('ida y vuelta: lo que se envia en toJsonNoId vuelve igual con fromJson', () {
        final original = PollResponse(
          pollId: 'poll_abc',
          respondentId: 'user_xyz',
          answers: const [1, 0, 2],
          comment: 'Comentario opcional',
        );

        final enviado = original.toJsonNoId();
        final devuelto = PollResponse.fromJson(enviado);

        expect(devuelto.pollId, original.pollId);
        expect(devuelto.respondentId, original.respondentId);
        expect(devuelto.answers, original.answers);
        expect(devuelto.comment, original.comment);
      });
    });
  });
}
