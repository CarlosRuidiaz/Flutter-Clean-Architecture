import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/profile/data/datasources/local/local_profile_source.dart';
import 'package:f_clean_template/features/project/data/datasources/local/local_project_source.dart';
import 'package:flutter_test/flutter_test.dart';

/// El emparejamiento entre proyectos y estudiantes depende de que unos y otros
/// hablen el mismo vocabulario. Estas pruebas son baratas y evitan que alguien
/// siembre "Flutter" o "Ingeniería Civil" y rompa el match sin enterarse.
void main() {
  group('AppCatalogs', () {
    test('no hay valores repetidos en ninguna lista', () {
      expect(AppCatalogs.skills.toSet().length, AppCatalogs.skills.length);
      expect(AppCatalogs.tags.toSet().length, AppCatalogs.tags.length);
      expect(
        AppCatalogs.academicPrograms.toSet().length,
        AppCatalogs.academicPrograms.length,
      );
    });

    test('todas las habilidades sembradas estan en el catalogo', () async {
      final projects = await LocalProjectSource().getProjects();
      for (final project in projects) {
        for (final skill in project.skillsWanted) {
          expect(
            AppCatalogs.skills,
            contains(skill),
            reason: 'el proyecto "${project.title}" pide una habilidad '
                'fuera del catalogo',
          );
        }
      }

      final profile = await LocalProfileSource().getCurrentProfile();
      for (final skill in profile.skills) {
        expect(AppCatalogs.skills, contains(skill));
      }

      final source = LocalApplicationSource();
      for (final projectId in ['1', '2', '3']) {
        for (final application in await source.getApplicationsFor(projectId)) {
          for (final skill in application.skillsOffered) {
            expect(AppCatalogs.skills, contains(skill));
          }
        }
      }
    });

    test('todos los programas sembrados estan en el catalogo', () async {
      final projects = await LocalProjectSource().getProjects();
      for (final project in projects) {
        expect(
          AppCatalogs.academicPrograms,
          contains(project.academicProgram),
          reason: 'el proyecto "${project.title}" tiene un programa '
              'fuera del catalogo',
        );
      }

      final profile = await LocalProfileSource().getCurrentProfile();
      expect(AppCatalogs.academicPrograms, contains(profile.academicProgram));

      final source = LocalApplicationSource();
      for (final projectId in ['1', '2', '3']) {
        for (final application in await source.getApplicationsFor(projectId)) {
          expect(
            AppCatalogs.academicPrograms,
            contains(application.applicantProgram),
          );
        }
      }
    });

    test('todos los tags sembrados estan en el catalogo', () async {
      final projects = await LocalProjectSource().getProjects();
      for (final project in projects) {
        for (final tag in project.tags) {
          expect(AppCatalogs.tags, contains(tag));
        }
      }
    });

    test('el perfil comparte habilidad con algun proyecto', () async {
      // Si esto falla, la pestania "Para tus habilidades" sale vacia siempre y
      // la app parece rota aunque el codigo este bien.
      final profile = await LocalProfileSource().getCurrentProfile();
      final projects = await LocalProjectSource().getProjects();

      expect(
        projects.any((p) => p.matchesAnySkill(profile.skills)),
        isTrue,
        reason: 'ningun proyecto sembrado pide una habilidad del perfil',
      );
    });
  });
}
