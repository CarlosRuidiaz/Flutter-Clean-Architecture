import 'dart:async';
import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/my_projects/ui/viewmodels/my_projects_controller.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/profile/ui/views/profile_view.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeAuthRepository implements IAuthRepository {
  final StreamController<bool> _session = StreamController<bool>.broadcast();

  @override
  Stream<bool> get sessionChanges => _session.stream;
  @override
  Future<AuthenticationUser?> getLoggedUser() async =>
      AuthenticationUser(id: 'u1', email: 't@t.com', name: 'T', password: '');
  @override
  Future<bool> login(AuthenticationUser u) async => true;
  @override
  Future<bool> restoreSession() async => true;
  @override
  Future<bool> signUp(AuthenticationUser u) async => true;
  @override
  Future<bool> logOut() async => true;
  @override
  Future<bool> validate(String e, String c) async => true;
  @override
  Future<bool> validateToken() async => true;
  @override
  Future<void> forgotPassword(String e) async {}
}

/// Perfil que devuelve null: simula un fallo de red.
class _FailingProfileRepository implements IProfileRepository {
  @override
  Future<Profile> getCurrentProfile() async =>
      throw Exception('Error de red simulado');
}

class _FakeProjectRepo implements IProjectRepository {
  @override
  Future<List<Project>> getProjects() async => [];
  @override
  Future<Project> createProject(Project p) async => throw UnimplementedError();
  @override
  Future<void> closeRecruitment(String id) async {}
  @override
  Future<void> addMember(String id) async {}
}

class _FakeAppRepo implements IApplicationRepository {
  @override
  Future<List<Application>> getMyApplications(String id) async => [];
  @override
  Future<List<Application>> getApplicationsFor(String id) async => [];
  @override
  Future<Application> apply(Application a) async => throw UnimplementedError();
  @override
  Future<void> withdraw(String id) async {}
  @override
  Future<void> decide(String id, ApplicationStatus d) async {}
}

void main() {
  group('ProfileView · error', () {
    setUp(() {
      final authRepo = _FakeAuthRepository();
      Get.put<IAuthRepository>(authRepo);
      Get.put<AuthenticationController>(AuthenticationController(authRepo));

      // ProfileController con repo que falla → profile queda nulo.
      final failingRepo = _FailingProfileRepository();
      Get.put<ProfileController>(ProfileController(failingRepo, authRepo));

      Get.put<MyProjectsController>(MyProjectsController(
        _FakeProjectRepo(),
        _FakeAppRepo(),
        failingRepo,
        authRepo,
      ));
    });

    tearDown(() => Get.deleteAll(force: true));

    testWidgets('con el perfil nulo se ve el mensaje, no el spinner',
        (tester) async {
      // Esperar a que el ProfileController termine de intentar cargar.
      await Future.delayed(const Duration(milliseconds: 50));

      await tester.pumpWidget(const GetMaterialApp(home: ProfileView()));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No pudimos cargar tu perfil'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });
}
