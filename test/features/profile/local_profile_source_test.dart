import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/profile/data/datasources/local/local_profile_source.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';

void main() {
  group('LocalProfileSource', () {
    late LocalProfileSource source;

    setUp(() {
      source = LocalProfileSource();
    });

    test('devuelve un perfil con nombre y programa', () async {
      final profile = await source.getCurrentProfile();
      expect(profile.fullName, 'Carlos Ruidíaz');
      expect(profile.academicProgram, 'Ingeniería de Sistemas');
    });

    test('devuelve al menos una habilidad', () async {
      final profile = await source.getCurrentProfile();
      expect(profile.skills, isNotEmpty);
      expect(profile.skills, contains('Investigación'));
      expect(profile.skills, contains('Diseño UX'));
    });

    test('el perfil de prueba esta completo', () async {
      final profile = await source.getCurrentProfile();
      expect(profile.isComplete, isTrue);
    });

    test('Profile.isComplete logic', () {
      final completeProfile = Profile(
        fullName: 'Test User',
        academicProgram: 'Test Program',
        semester: 1,
        skills: ['Skill 1'],
      );
      expect(completeProfile.isComplete, isTrue);

      final incompleteName = Profile(
        fullName: '',
        academicProgram: 'Test Program',
        semester: 1,
        skills: ['Skill 1'],
      );
      expect(incompleteName.isComplete, isFalse);

      final incompleteSkills = Profile(
        fullName: 'Test User',
        academicProgram: 'Test Program',
        semester: 1,
        skills: [],
      );
      expect(incompleteSkills.isComplete, isFalse);
    });
  });
}
