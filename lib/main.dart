import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

import 'central.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'core/i_local_preferences.dart';
import 'core/local_preferences_secured.dart';
import 'core/local_preferences_shared.dart';
import 'core/roble_config.dart';

import 'features/application/application_dependencies.dart';
import 'features/auth/auth_dependencies.dart';
import 'features/management/management_dependencies.dart';
import 'features/my_projects/my_projects_dependencies.dart';
import 'features/product/product_dependencies.dart';
import 'features/profile/profile_dependencies.dart';
import 'features/project/project_dependencies.dart';
import 'features/workspace/workspace_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  final ILocalPreferences preferences = kIsWeb
      ? LocalPreferencesShared()
      : LocalPreferencesSecured();
  Get.put<ILocalPreferences>(preferences, permanent: true);

  // Una sola instancia, compartida: cada copia tendria su propia sesion.
  Get.put<RobleApiDataBase>(
    RobleApiDataBase(
      config: RobleApiConfig.fromContract(
        baseUrl: RobleConfig.baseUrl,
        contractId: RobleConfig.contractId,
      ),
    ),
    permanent: true,
  );

  registerAuth();
  registerProduct();
  registerProfile();
  registerProject();
  registerApplication();
  // Va despues de los dos anteriores: resuelve sus repositorios.
  registerManagement();
  registerWorkspace();
  registerMyProjects();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Innovation Hub',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const Central(),
      getPages: AppRoutes.pages,
    );
  }
}
