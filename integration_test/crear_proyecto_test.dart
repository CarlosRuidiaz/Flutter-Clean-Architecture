import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/features/project/data/datasources/i_project_source.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'app_de_prueba.dart';
import 'ayudas.dart';
import 'fakes/fake_authentication_source.dart';

const String _email = 'ana.perez@uninorte.edu.co';
const String _contrasena = 'Clave!2026';
const String _titulo = 'App de movilidad sostenible para el campus';

const UsuarioSembrado _ana = UsuarioSembrado(
  email: _email,
  password: _contrasena,
  name: 'Ana Pérez',
  academicProgram: AppCatalogs.programSystems,
  semester: 5,
  skills: [AppCatalogs.skillWeb],
);

bool _publicarHabilitado(WidgetTester tester) =>
    tester.widget<ElevatedButton>(porLlave('ButtonIdeaPublish')).onPressed !=
    null;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo: crear proyecto', () {
    testWidgets('quien inicia sesion publica una idea y la ve en explorar, '
        'con su cuenta como lider', (tester) async {
      final auth = await arrancarAppDePrueba(tester, usuarios: const [_ana]);

      await iniciarSesion(tester, email: _email, password: _contrasena);
      expect(porLlave('HomePage'), findsOneWidget);

      // 1. El boton de crear abre el formulario, y vacio no deja publicar.
      await tocar(tester, porLlave('NavCrear'));
      expect(porLlave('CreateIdeaPage'), findsOneWidget);
      expect(_publicarHabilitado(tester), isFalse);

      // 2. Lo esencial: titulo, problema y descripcion.
      await escribir(tester, 'TextFormFieldIdeaTitle', _titulo);
      await escribir(
        tester,
        'TextFormFieldIdeaProblem',
        'Mucha gente llega al campus en carro y faltan cupos.',
      );
      await escribir(
        tester,
        'TextFormFieldIdeaDescription',
        'Una app para coordinar viajes compartidos entre estudiantes.',
      );
      expect(_publicarHabilitado(tester), isFalse);

      // 3. El equipo: una habilidad, mas gente y la etapa actual.
      await tocar(
        tester,
        porLlave('ChipIdeaSkill-${AppCatalogs.skillWeb}'),
      );
      await tocar(
        tester,
        find.descendant(
          of: porLlave('FieldIdeaMaxMembers'),
          matching: find.byIcon(Icons.add),
        ),
      );
      expect(_publicarHabilitado(tester), isFalse);
      await tocar(tester, porLlave('ChipIdeaStage-${ProjectStage.idea.name}'));

      // 4. Con todo lo obligatorio, ya se puede publicar.
      expect(_publicarHabilitado(tester), isTrue);
      await tocar(tester, porLlave('ButtonIdeaPublish'));

      expect(porLlave('IdeaPublishedPage'), findsOneWidget);
      expect(porLlave('CreateIdeaPage'), findsNothing);

      // 5. Vuelve al inicio y el proyecto aparece al explorar.
      await tocar(tester, porLlave('ButtonIdeaPublishedHome'));
      expect(porLlave('HomePage'), findsOneWidget);
      await tocar(tester, porLlave('TabExplorar'));
      await escribir(tester, 'TextFieldSearch', 'movilidad');
      expect(find.text(_titulo), findsWidgets);

      // 6. En la fuente quedo guardado, con la cuenta de Ana como lider.
      final proyectos = await Get.find<IProjectSource>().getProjects();
      final creado = proyectos.where((p) => p.title == _titulo).toList();
      expect(creado, hasLength(1));
      expect(creado.single.leaderId, auth.cuentaConSesion!.id);
      expect(creado.single.stage, ProjectStage.idea);
      expect(creado.single.skillsWanted, [AppCatalogs.skillWeb]);
      expect(creado.single.maxMembers, 3);
      expect(creado.single.academicProgram, AppCatalogs.programSystems);
    });
  });
}
