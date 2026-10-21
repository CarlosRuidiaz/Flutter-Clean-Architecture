import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/application/domain/models/application.dart';

void main() {
  group('Application', () {
    group('canWithdraw', () {
      Application crear(ApplicationStatus status) => Application(
            projectId: 'p1',
            applicantId: 'u1',
            applicantName: 'Ana',
            applicantProgram: 'Sistemas',
            applicantSemester: 5,
            skillsOffered: const [],
            status: status,
          );

      test('es verdadero unicamente cuando el estado es pending', () {
        expect(crear(ApplicationStatus.pending).canWithdraw, isTrue);
        expect(crear(ApplicationStatus.pending).isPending, isTrue);
      });

      test('es falso para cualquier otro estado', () {
        expect(crear(ApplicationStatus.accepted).canWithdraw, isFalse);
        expect(crear(ApplicationStatus.rejected).canWithdraw, isFalse);
        expect(crear(ApplicationStatus.withdrawn).canWithdraw, isFalse);
        expect(crear(ApplicationStatus.left).canWithdraw, isFalse);
        expect(crear(ApplicationStatus.removed).canWithdraw, isFalse);
      });
    });

    group('fromJson y toJson', () {
      test('fromJson con datos completos mapea cada atributo', () {
        final json = {
          '_id': 'app123',
          'project_id': 'proj1',
          'applicant_id': 'user42',
          'applicant_name': 'Ana Silva',
          'applicant_program': 'Diseno Industrial',
          'applicant_semester': 6,
          'skills_offered': ['Figma', 'Prototyping'],
          'status': 'accepted',
        };

        final application = Application.fromJson(json);

        expect(application.id, 'app123');
        expect(application.projectId, 'proj1');
        expect(application.applicantId, 'user42');
        expect(application.applicantName, 'Ana Silva');
        expect(application.applicantProgram, 'Diseno Industrial');
        expect(application.applicantSemester, 6);
        expect(application.skillsOffered, ['Figma', 'Prototyping']);
        expect(application.status, ApplicationStatus.accepted);
      });

      test('fromJson con datos que faltan o vienen mal usa valores por defecto sin reventar', () {
        final jsonInvalido = <String, dynamic>{
          'applicant_semester': 'no_es_numero',
          'skills_offered': 'texto_plano_no_json',
          'status': 'estado_inexistente',
        };

        final application = Application.fromJson(jsonInvalido);

        expect(application.id, isNull);
        expect(application.projectId, isEmpty);
        expect(application.applicantId, isEmpty);
        expect(application.applicantName, isEmpty);
        expect(application.applicantProgram, isEmpty);
        expect(application.applicantSemester, 0);
        expect(application.skillsOffered, isEmpty);
        expect(application.status, ApplicationStatus.pending);
      });

      test('fromJson maneja skills_offered como texto JSON codificado y status nulo', () {
        final json = {
          '_id': 'app124',
          'project_id': 'proj2',
          'applicant_id': 'user43',
          'applicant_name': 'Carlos',
          'applicant_program': 'Sistemas',
          'applicant_semester': '4',
          'skills_offered': jsonEncode(['Flutter', 'Firebase']),
          'status': null,
        };

        final application = Application.fromJson(json);

        expect(application.skillsOffered, ['Flutter', 'Firebase']);
        expect(application.applicantSemester, 4);
        expect(application.status, ApplicationStatus.pending);
      });

      test('toJsonNoId contiene las columnas correctas sin id y con listas en texto json', () {
        final application = Application(
          id: 'ignorar_este_id',
          projectId: 'proj1',
          applicantId: 'user42',
          applicantName: 'Ana Silva',
          applicantProgram: 'Diseno Industrial',
          applicantSemester: 6,
          skillsOffered: const ['Figma', 'Prototyping'],
          status: ApplicationStatus.pending,
        );

        final jsonNoId = application.toJsonNoId();

        expect(jsonNoId.containsKey('_id'), isFalse);
        expect(jsonNoId.containsKey('id'), isFalse);
        expect(jsonNoId['project_id'], 'proj1');
        expect(jsonNoId['applicant_id'], 'user42');
        expect(jsonNoId['applicant_name'], 'Ana Silva');
        expect(jsonNoId['applicant_program'], 'Diseno Industrial');
        expect(jsonNoId['applicant_semester'], 6);
        expect(jsonNoId['skills_offered'], jsonEncode(['Figma', 'Prototyping']));
        expect(jsonNoId['skills_offered'], isA<String>());
        expect(jsonNoId['status'], 'pending');
      });

      test('toJson normal conserva el id si existe', () {
        final application = Application(
          id: 'app123',
          projectId: 'proj1',
          applicantId: 'user42',
          applicantName: 'Ana Silva',
          applicantProgram: 'Diseno Industrial',
          applicantSemester: 6,
          skillsOffered: const ['Figma'],
          status: ApplicationStatus.accepted,
        );

        final json = application.toJson();
        expect(json['_id'], 'app123');
        expect(json['project_id'], 'proj1');
        expect(json['skills_offered'], ['Figma']);
        expect(json['status'], 'accepted');
      });

      test('ida y vuelta: lo que se envia en toJsonNoId vuelve igual con fromJson', () {
        final original = Application(
          projectId: 'proj9',
          applicantId: 'u9',
          applicantName: 'Ana Garcia',
          applicantProgram: 'Ing. de Sistemas',
          applicantSemester: 8,
          skillsOffered: const ['Python', 'Investigacion'],
          status: ApplicationStatus.accepted,
        );

        final enviado = original.toJsonNoId();
        final devuelto = Application.fromJson(enviado);

        expect(devuelto.projectId, original.projectId);
        expect(devuelto.applicantId, original.applicantId);
        expect(devuelto.applicantName, original.applicantName);
        expect(devuelto.applicantProgram, original.applicantProgram);
        expect(devuelto.applicantSemester, original.applicantSemester);
        expect(devuelto.skillsOffered, original.skillsOffered);
        expect(devuelto.status, original.status);
      });

      test('los estados left y removed se leen y se escriben por su nombre', () {
        Application leer(String status) => Application.fromJson({
              '_id': 'a',
              'project_id': 'p',
              'applicant_id': 'u',
              'applicant_name': 'n',
              'applicant_program': 'x',
              'applicant_semester': 1,
              'skills_offered': [],
              'status': status,
            });

        expect(leer('left').status, ApplicationStatus.left);
        expect(leer('removed').status, ApplicationStatus.removed);
        expect(leer('left').toJsonNoId()['status'], 'left');
        expect(leer('removed').toJsonNoId()['status'], 'removed');
      });
    });
  });
}
