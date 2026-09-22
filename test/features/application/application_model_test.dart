import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/application/domain/models/application.dart';

void main() {
  group('Application model JSON', () {
    test('fromJson y toJson ida y vuelta con lista normal', () {
      final json = {
        '_id': 'app123',
        'project_id': 'proj1',
        'applicant_id': 'user42',
        'applicant_name': 'Ana Silva',
        'applicant_program': 'Diseño Industrial',
        'applicant_semester': 6,
        'skills_offered': ['Figma', 'Prototyping'],
        'status': 'accepted',
      };

      final application = Application.fromJson(json);

      expect(application.id, 'app123');
      expect(application.projectId, 'proj1');
      expect(application.applicantId, 'user42');
      expect(application.applicantName, 'Ana Silva');
      expect(application.applicantProgram, 'Diseño Industrial');
      expect(application.applicantSemester, 6);
      expect(application.skillsOffered, ['Figma', 'Prototyping']);
      expect(application.status, ApplicationStatus.accepted);

      final toJson = application.toJson();
      expect(toJson['_id'], 'app123');
      expect(toJson['project_id'], 'proj1');
      expect(toJson['status'], 'accepted');
      expect(toJson['skills_offered'], ['Figma', 'Prototyping']);

      final toJsonNoId = application.toJsonNoId();
      expect(toJsonNoId.containsKey('_id'), false);
      expect(toJsonNoId.containsKey('id'), false);
      expect(toJsonNoId['project_id'], 'proj1');
    });

    test('fromJson maneja skills_offered que llega como string JSON', () {
      final json = {
        '_id': 'app124',
        'project_id': 'proj2',
        'applicant_id': 'user43',
        'applicant_name': 'Carlos',
        'applicant_program': 'Sistemas',
        'applicant_semester': 4,
        'skills_offered': jsonEncode(['Flutter', 'Firebase']),
        'status': 'pending',
      };

      final application = Application.fromJson(json);

      expect(application.skillsOffered, ['Flutter', 'Firebase']);
      expect(application.status, ApplicationStatus.pending);
    });

    test('fromJson usa status por defecto pending ante status desconocido o nulo', () {
      final jsonUnknown = {
        '_id': 'app125',
        'project_id': 'proj3',
        'applicant_id': 'user44',
        'applicant_name': 'David',
        'applicant_program': 'Civil',
        'applicant_semester': 2,
        'skills_offered': [],
        'status': 'in_progress',
      };

      final applicationUnknown = Application.fromJson(jsonUnknown);
      expect(applicationUnknown.status, ApplicationStatus.pending);

      final jsonNull = {
        ...jsonUnknown,
        'status': null,
      };
      final applicationNull = Application.fromJson(jsonNull);
      expect(applicationNull.status, ApplicationStatus.pending);
    });
  });
}
