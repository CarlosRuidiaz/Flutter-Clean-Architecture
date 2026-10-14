import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/application/data/repositories/application_repository.dart';
import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/ui/viewmodels/application_controller.dart';
import 'package:f_clean_template/features/project/data/datasources/local/local_project_source.dart';
import 'package:f_clean_template/features/project/data/repositories/project_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Application _postulacion({
  required String projectId,
  required String applicantId,
  String name = 'Estudiante',
}) => Application(
  projectId: projectId,
  applicantId: applicantId,
  applicantName: name,
  applicantProgram: 'Ing. de Sistemas',
  applicantSemester: 5,
  skillsOffered: const [],
);

void main() {
  group('ApplicationController', () {
    late ApplicationRepository repository;
    late ApplicationController controller;

    setUp(() {
      repository = ApplicationRepository(LocalApplicationSource());
      // El proyecto '2' lo lidera '1'; el '5' lo lidera 'u4'.
      controller = ApplicationController(
        repository,
        ProjectRepository(LocalProjectSource()),
      );
    });

    group('el lider no se postula a lo suyo', () {
      test('apply no crea nada si el postulante es el lider', () async {
        final antes = (await repository.getApplicationsFor('2')).length;

        final resultado = await controller.apply(
          _postulacion(projectId: '2', applicantId: '1'),
        );

        expect(resultado, isNull);
        expect((await repository.getApplicationsFor('2')).length, antes);
      });

      test('quien no lidera si se postula', () async {
        final resultado = await controller.apply(
          _postulacion(projectId: '5', applicantId: 'u9'),
        );

        expect(resultado, isNotNull);
        expect(resultado!.isPending, isTrue);
        expect(controller.vigenteEn('5')?.id, resultado.id);
      });
    });

    group('quien salio o fue removido', () {
      test('una postulacion en left no es vigente y puede volver a postularse',
          () async {
        final creada = await controller.apply(
          _postulacion(projectId: '5', applicantId: 'u9'),
        );
        await repository.decide(creada!.id!, ApplicationStatus.accepted);
        await repository.leave(creada.id!);
        await controller.getMyApplications('u9');

        expect(controller.vigenteEn('5'), isNull);
        expect(controller.fueRemovidoDe('5'), isFalse);

        final otra = await controller.apply(
          _postulacion(projectId: '5', applicantId: 'u9'),
        );
        expect(otra!.id, isNot(creada.id));
        expect(otra.isPending, isTrue);
      });

      test('un removido lo sabe el controlador y no vuelve a postularse',
          () async {
        final creada = await controller.apply(
          _postulacion(projectId: '5', applicantId: 'u9'),
        );
        await repository.decide(creada!.id!, ApplicationStatus.removed);
        await controller.getMyApplications('u9');

        expect(controller.fueRemovidoDe('5'), isTrue);
        expect(controller.fueRemovidoDe('2'), isFalse);
        expect(controller.vigenteEn('5'), isNull);

        final intento = await controller.apply(
          _postulacion(projectId: '5', applicantId: 'u9'),
        );

        // Le devuelve la suya, ya removida, y no crea otra.
        expect(intento!.id, creada.id);
        expect(intento.status, ApplicationStatus.removed);
        expect((await repository.getMyApplications('u9')).length, 1);
      });
    });

    test('withdraw sin saber de quien es no adivina un estudiante', () async {
      // La lista de postulaciones del controlador esta vacia: no hay a quien
      // recargarle nada. No debe fallar ni inventar un id.
      await controller.withdraw('1');

      expect(controller.myApplications, isEmpty);
    });
  });
}
