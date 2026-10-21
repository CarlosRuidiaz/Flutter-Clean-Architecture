import 'package:f_clean_template/core/i_local_preferences.dart';
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
  }) async =>
      [];
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
  tearDown(() => Get.deleteAll(force: true));

  test('la app registra todas sus dependencias en el orden de main.dart',
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
  });
}
