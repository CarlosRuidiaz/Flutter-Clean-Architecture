import '../models/profile.dart';

abstract class IProfileRepository {
  Future<Profile> getCurrentProfile();
}
