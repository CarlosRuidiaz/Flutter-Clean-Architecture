import 'package:f_clean_template/core/i_local_preferences.dart';
import 'package:f_clean_template/features/application/data/datasources/i_application_source.dart';
import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/application/ui/viewmodels/application_controller.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/authentication_source_service.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/i_authentication_source.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/follow/data/datasources/i_follow_source.dart';
import 'package:f_clean_template/features/follow/data/datasources/local/local_follow_source.dart';
import 'package:f_clean_template/features/management/ui/viewmodels/management_controller.dart';
import 'package:f_clean_template/features/poll/data/datasources/i_poll_source.dart';
import 'package:f_clean_template/features/poll/data/datasources/local/local_poll_source.dart';
import 'package:f_clean_template/features/profile/data/datasources/i_profile_source.dart';
import 'package:f_clean_template/features/profile/data/datasources/local/local_profile_source.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/project/data/datasources/i_project_source.dart';
import 'package:f_clean_template/features/project/data/datasources/local/local_project_source.dart';
import 'package:f_clean_template/features/project/ui/viewmodels/project_controller.dart';
import 'package:f_clean_template/features/showcase/data/datasources/i_showcase_source.dart';
import 'package:f_clean_template/features/showcase/data/datasources/local/local_showcase_source.dart';
import 'package:f_clean_template/features/workspace/data/datasources/i_workspace_source.dart';
import 'package:f_clean_template/features/workspace/data/datasources/local/local_workspace_source.dart';
import 'package:f_clean_template/features/application/application_dependencies.dart';
import 'package:f_clean_template/features/auth/auth_dependencies.dart';
import 'package:f_clean_template/features/follow/follow_dependencies.dart';
import 'package:f_clean_template/features/follow/ui/viewmodels/follow_controller.dart';
import 'package:f_clean_template/features/management/management_dependencies.dart';
import 'package:f_clean_template/features/my_projects/my_projects_dependencies.dart';
import 'package:f_clean_template/features/my_projects/ui/viewmodels/my_projects_controller.dart';
import 'package:f_clean_template/features/poll/poll_dependencies.dart';
import 'package:f_clean_template/features/poll/ui/viewmodels/poll_controller.dart';
import 'package:f_clean_template/features/product/product_dependencies.dart';
import 'package:f_clean_template/features/profile/profile_dependencies.dart';
import 'package:f_clean_template/features/project/project_dependencies.dart';
import 'package:f_clean_template/features/showcase/showcase_dependencies.dart';
import 'package:f_clean_template/features/showcase/ui/viewmodels/showcase_controller.dart';
import 'package:f_clean_template/features/workspace/ui/viewmodels/workspace_controller.dart';
import 'package:f_clean_template/features/workspace/workspace_dependencies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:roble/roble.dart';

/// Roble sin red: no hay sesion guardada y toda tabla llega vacia.
class _RobleSinRed extends RobleApiDataBase {
  _RobleSinRed()
    : super(
        config: RobleApiConfig.fromContract(
          baseUrl: 'https://roble.test-openlab.uninorte.edu.co',
          contractId: 'proyecto_test_12345678',
        ),
      );

  @override
  Future<bool> restoreSession({bool verify = true}) async => false;

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async => [];
}

class _PreferenciasEnMemoria implements ILocalPreferences {
  final Map<String, Object> _valores = <String, Object>{};

  @override
  Future<void> clear() async => _valores.clear();
  @override
  Future<bool?> getBool(String key) async => _valores[key] as bool?;
  @override
  Future<double?> getDouble(String key) async => _valores[key] as double?;
  @override
  Future<int?> getInt(String key) async => _valores[key] as int?;
  @override
  Future<String?> getString(String key) async => _valores[key] as String?;
  @override
  Future<List<String>?> getStringList(String key) async =>
      (_valores[key] as List<String>?)?.toList();
  @override
  Future<void> remove(String key) async => _valores.remove(key);
  @override
  Future<void> setBool(String key, bool value) async => _valores[key] = value;
  @override
  Future<void> setDouble(String key, double value) async =>
      _valores[key] = value;
  @override
  Future<void> setInt(String key, int value) async => _valores[key] = value;
  @override
  Future<void> setString(String key, String value) async =>
      _valores[key] = value;
  @override
  Future<void> setStringList(String key, List<String> value) async =>
      _valores[key] = value.toList();
}

void main() {
  // resetInstance y no deleteAll: deleteAll deja las fabricas de los lazyPut
  // con fenix, y el register siguiente no las reemplazaria por las nuevas.
  tearDown(() => GetInstance().resetInstance());

  test(
    'la app registra todas sus dependencias en el orden de main.dart',
    () async {
      // En modo prueba seguir y encuestas eligen su fuente local.
      Get.testMode = true;
      Get.put<ILocalPreferences>(_PreferenciasEnMemoria(), permanent: true);
      Get.put<RobleApiDataBase>(_RobleSinRed(), permanent: true);

      // El mismo orden que main.dart.
      registerAuth();
      registerProduct();
      registerProfile();
      registerProject();
      registerApplication();
      registerManagement();
      registerWorkspace();
      registerFollow();
      registerMyProjects();
      registerShowcase();
      registerPoll();

      expect(Get.find<FollowController>(), isA<FollowController>());
      expect(Get.find<PollController>(), isA<PollController>());
      expect(Get.find<ShowcaseController>(), isA<ShowcaseController>());
      expect(Get.find<WorkspaceController>(), isA<WorkspaceController>());
      expect(Get.find<MyProjectsController>(), isA<MyProjectsController>());

      // Las cargas que arrancan los onInit terminan sin lanzar.
      await pumpEventQueue();
    },
  );

  test(
    'con todas las fuentes inyectadas la app se registra sin roble',
    () async {
      Get.testMode = true;
      final preferencias = _PreferenciasEnMemoria();
      Get.put<ILocalPreferences>(preferencias, permanent: true);

      final auth = AuthenticationSourceService(preferencias);
      final perfiles = LocalProfileSource();
      final proyectos = LocalProjectSource();
      final postulaciones = LocalApplicationSource();
      final espacio = LocalWorkspaceSource();
      final seguir = LocalFollowSource();
      final vitrina = LocalShowcaseSource();
      final encuestas = LocalPollSource();

      // El mismo orden que main.dart, ahora con cada fuente pasada a mano.
      registerAuth(source: auth);
      registerProduct();
      registerProfile(source: perfiles);
      registerProject(source: proyectos);
      registerApplication(source: postulaciones);
      registerManagement();
      registerWorkspace(source: espacio);
      registerFollow(source: seguir);
      registerMyProjects();
      registerShowcase(source: vitrina);
      registerPoll(source: encuestas);

      expect(
        Get.find<AuthenticationController>(),
        isA<AuthenticationController>(),
      );
      expect(Get.find<ProfileController>(), isA<ProfileController>());
      expect(Get.find<ProjectController>(), isA<ProjectController>());
      expect(Get.find<ApplicationController>(), isA<ApplicationController>());
      expect(Get.find<ManagementController>(), isA<ManagementController>());
      expect(Get.find<WorkspaceController>(), isA<WorkspaceController>());
      expect(Get.find<FollowController>(), isA<FollowController>());
      expect(Get.find<MyProjectsController>(), isA<MyProjectsController>());
      expect(Get.find<ShowcaseController>(), isA<ShowcaseController>());
      expect(Get.find<PollController>(), isA<PollController>());

      // Las fuentes registradas son las que se pasaron, no las de Roble.
      expect(Get.find<IAuthenticationSource>(), same(auth));
      expect(Get.find<IProfileSource>(), same(perfiles));
      expect(Get.find<IProjectSource>(), same(proyectos));
      expect(Get.find<IApplicationSource>(), same(postulaciones));
      expect(Get.find<IWorkspaceSource>(), same(espacio));
      expect(Get.find<IFollowSource>(), same(seguir));
      expect(Get.find<IShowcaseSource>(), same(vitrina));
      expect(Get.find<IPollSource>(), same(encuestas));
      expect(Get.isRegistered<RobleApiDataBase>(), isFalse);

      await pumpEventQueue();
    },
  );
}
