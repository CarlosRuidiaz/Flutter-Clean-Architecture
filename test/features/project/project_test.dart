import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:flutter_test/flutter_test.dart';

Project _conHabilidades(List<String> skillsWanted) => Project(
      title: 'Un proyecto',
      problem: 'Un problema',
      description: 'Una descripcion',
      stage: ProjectStage.idea,
      academicProgram: 'Ingeniería',
      currentMembers: 1,
      maxMembers: 4,
      skillsWanted: skillsWanted,
      leaderId: 'u1',
    );

void main() {
  group('Project.matchesAnySkill', () {
    test('coincide si comparten al menos una habilidad', () {
      final project = _conHabilidades(['Flutter', 'Backend']);
      expect(project.matchesAnySkill(['Backend']), isTrue);
    });

    test('no coincide si no comparten ninguna', () {
      final project = _conHabilidades(['Flutter']);
      expect(project.matchesAnySkill(['Marketing']), isFalse);
    });

    test('no distingue mayusculas ni espacios de sobra', () {
      final project = _conHabilidades(['  Diseño UX ']);
      expect(project.matchesAnySkill(['diseño ux']), isTrue);
    });

    test('sin habilidades del estudiante devuelve false', () {
      final project = _conHabilidades(['Flutter']);
      expect(project.matchesAnySkill(const []), isFalse);
    });

    test('un proyecto que no pide habilidades no encaja con nadie', () {
      final project = _conHabilidades(const []);
      expect(project.matchesAnySkill(['Flutter']), isFalse);
    });

    test('las cadenas vacias no cuentan como coincidencia', () {
      final project = _conHabilidades(['   ']);
      expect(project.matchesAnySkill(['']), isFalse);
    });
  });
}
