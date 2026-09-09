import '../../domain/models/profile.dart';

abstract class IProfileSource {
  Future<Profile> getCurrentProfile();
}
