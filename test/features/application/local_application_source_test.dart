import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalApplicationSource', () {
    late LocalApplicationSource source;

    setUp(() {
      source = LocalApplicationSource();
    });

    test('getMyApplications solo devuelve las del estudiante pedido', () async {
      final apps = await source.getMyApplications('1');
      expect(apps.isNotEmpty, isTrue);
      for (final app in apps) {
        expect(app.applicantId, '1');
      }

      final otherApps = await source.getMyApplications('u7');
      expect(otherApps.length, 1);
      expect(otherApps.first.applicantId, 'u7');
    });

    test('getApplicationsFor solo devuelve las del proyecto pedido', () async {
      final appsProj2 = await source.getApplicationsFor('2');
      expect(appsProj2.length, 2);
      for (final app in appsProj2) {
        expect(app.projectId, '2');
      }

      final appsProj1 = await source.getApplicationsFor('1');
      expect(appsProj1.length, 1);
      expect(appsProj1.first.projectId, '1');
    });

    test('apply asigna un id y la postulacion queda guardada', () async {
      final nueva = Application(
        projectId: '5',
        applicantId: '1',
        applicantName: 'Carlos Ruidíaz',
        applicantProgram: 'Ingeniería de Sistemas',
        applicantSemester: 8,
        skillsOffered: ['Investigación'],
        status: ApplicationStatus.pending,
      );

      final creada = await source.apply(nueva);
      expect(creada.id, isNotNull);
      expect(creada.id, '5');
      expect(creada.projectId, '5');

      final misApps = await source.getMyApplications('1');
      expect(misApps.any((a) => a.id == creada.id), isTrue);
    });

    test('withdraw deja la postulacion en withdrawn', () async {
      final misApps = await source.getMyApplications('1');
      final pendiente = misApps.firstWhere((a) => a.isPending);
      final id = pendiente.id!;

      await source.withdraw(id);

      final actualizadas = await source.getMyApplications('1');
      final retirada = actualizadas.firstWhere((a) => a.id == id);
      expect(retirada.status, ApplicationStatus.withdrawn);
      expect(retirada.canWithdraw, isFalse);
    });

    test('decide con accepted deja la postulacion en accepted', () async {
      final apps = await source.getApplicationsFor('2');
      final app = apps.first;
      final id = app.id!;

      await source.decide(id, ApplicationStatus.accepted);

      final actualizadas = await source.getApplicationsFor('2');
      final decidida = actualizadas.firstWhere((a) => a.id == id);
      expect(decidida.status, ApplicationStatus.accepted);
    });
  });
}
