import 'dart:async';

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../domain/models/profile.dart';
import '../../domain/repositories/i_profile_repository.dart';

class ProfileController extends GetxController with UiLoggy {
  ProfileController(this.repository, this.authRepository);

  final IProfileRepository repository;

  /// Por la interfaz, no por Roble: el controlador no sabe que hay detras.
  final IAuthRepository authRepository;

  final Rxn<Profile> _profile = Rxn<Profile>();
  final RxBool isLoading = false.obs;
  StreamSubscription<bool>? _sesion;

  Profile? get profile => _profile.value;

  @override
  void onInit() {
    getCurrentProfile();
    // El perfil es de quien tenga la sesion: si cambia, este deja de valer.
    _sesion = authRepository.sessionChanges.listen((haySesion) {
      loggy.debug('ProfileController: la sesion cambio (activa: $haySesion)');
      if (haySesion) {
        getCurrentProfile();
      } else {
        _profile.value = null;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    _sesion?.cancel();
    super.onClose();
  }

  Future<void> getCurrentProfile() async {
    loggy.debug('ProfileController: pidiendo el perfil');
    isLoading.value = true;
    try {
      _profile.value = await repository.getCurrentProfile();
    } catch (e) {
      // Sin sesion no hay perfil, y eso no es un fallo que deba reventar una
      // pantalla: se deja vacio y quien lo pinte decidira que mostrar.
      loggy.warning('ProfileController: no se pudo cargar el perfil: $e');
      _profile.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
