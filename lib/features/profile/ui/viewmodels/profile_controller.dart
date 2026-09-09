import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/profile.dart';
import '../../domain/repositories/i_profile_repository.dart';

class ProfileController extends GetxController with UiLoggy {
  ProfileController(this.repository);

  final IProfileRepository repository;

  // Rxn = observable que PUEDE ser nulo. Al arrancar todavía no hay perfil.
  final Rxn<Profile> _profile = Rxn<Profile>();
  final RxBool isLoading = false.obs;

  Profile? get profile => _profile.value;

  @override
  void onInit() {
    getCurrentProfile();
    super.onInit();
  }

  Future<void> getCurrentProfile() async {
    loggy.debug('ProfileController: pidiendo el perfil');
    isLoading.value = true;
    _profile.value = await repository.getCurrentProfile();
    isLoading.value = false;
  }
}
