import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/application.dart';
import '../../domain/repositories/i_application_repository.dart';

/// Esqueleto del controlador de las pantallas 14 y 19 (el lado del postulante).
/// El carril `application` llena los cuerpos.
class ApplicationController extends GetxController with UiLoggy {
  ApplicationController(this.repository);

  final IApplicationRepository repository;

  final RxList<Application> _myApplications = <Application>[].obs;
  final RxBool isLoading = false.obs;

  List<Application> get myApplications => _myApplications;

  Future<void> getMyApplications(String applicantId) async {
    // TODO(carril application): pedir al repositorio y llenar _myApplications,
    // con isLoading en true mientras tanto.
  }

  Future<void> apply(Application application) async {
    // TODO(carril application): postularse (pantalla 07 -> hoja modal 15).
  }

  Future<void> withdraw(String applicationId) async {
    // TODO(carril application): cancelar la postulacion (pantalla 14).
  }
}
