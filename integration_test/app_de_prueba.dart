import 'package:f_clean_template/core/i_local_preferences.dart';
import 'package:f_clean_template/features/application/application_dependencies.dart';
import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/auth/auth_dependencies.dart';
import 'package:f_clean_template/features/follow/data/datasources/local/local_follow_source.dart';
import 'package:f_clean_template/features/follow/follow_dependencies.dart';
import 'package:f_clean_template/features/management/management_dependencies.dart';
import 'package:f_clean_template/features/my_projects/my_projects_dependencies.dart';
import 'package:f_clean_template/features/poll/data/datasources/local/local_poll_source.dart';
import 'package:f_clean_template/features/poll/poll_dependencies.dart';
import 'package:f_clean_template/features/product/product_dependencies.dart';
import 'package:f_clean_template/features/profile/profile_dependencies.dart';
import 'package:f_clean_template/features/project/data/datasources/local/local_project_source.dart';
import 'package:f_clean_template/features/project/project_dependencies.dart';
import 'package:f_clean_template/features/showcase/data/datasources/local/local_showcase_source.dart';
import 'package:f_clean_template/features/showcase/showcase_dependencies.dart';
import 'package:f_clean_template/features/workspace/data/datasources/local/local_workspace_source.dart';
import 'package:f_clean_template/features/workspace/workspace_dependencies.dart';
import 'package:f_clean_template/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fakes/fake_authentication_source.dart';
import 'fakes/fake_local_preferences.dart';
import 'fakes/fake_profile_source.dart';

/// Arranca la app completa, la de `main.dart`, pero con todas las fuentes de
/// datos en memoria: no hay ninguna comunicacion con el servidor.
///
/// Cada llamada empieza de cero: se vacia GetX, se crean fuentes nuevas y se
/// monta un arbol nuevo. Devuelve la fuente de autenticacion para poder mirar
/// que cuentas quedaron guardadas; las demas fuentes se piden con
/// `Get.find<IProjectSource>()`.
Future<FakeAuthenticationSource> arrancarAppDePrueba(
  WidgetTester tester, {
  List<UsuarioSembrado> usuarios = const [],
}) async {
  Get.reset();

  final auth = FakeAuthenticationSource(usuarios: usuarios);
  Get.put<ILocalPreferences>(FakeLocalPreferences(), permanent: true);

  // El mismo orden que main.dart, cada uno con su fuente en memoria. No se
  // registra la base de datos de Roble: si algo la pidiera con `Get.find`,
  // faltaria pasarle una fuente a algun `register...()`.
  registerAuth(source: auth);
  registerProduct();
  registerProfile(source: FakeProfileSource(auth));
  registerProject(source: LocalProjectSource());
  registerApplication(source: LocalApplicationSource());
  // Va despues de los dos anteriores: resuelve sus repositorios.
  registerManagement();
  registerWorkspace(source: LocalWorkspaceSource());
  registerFollow(source: LocalFollowSource());
  registerMyProjects();
  registerShowcase(source: LocalShowcaseSource());
  registerPoll(source: LocalPollSource());

  // La llave unica obliga a montar un arbol nuevo. Sin ella, la segunda prueba
  // recibiria el mismo `MyApp` constante y Flutter no lo reconstruiria: se
  // quedaria con la pila de pantallas de la prueba anterior.
  await tester.pumpWidget(MyApp(key: UniqueKey()));
  await tester.pumpAndSettle();

  return auth;
}
