import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/paper_card.dart';
import '../../../../core/widgets/pill.dart';
import '../../../application/domain/models/application.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../profile/ui/viewmodels/profile_controller.dart';
import '../../../project/domain/models/project.dart';
import '../../../project/ui/viewmodels/project_controller.dart';
import '../viewmodels/management_controller.dart';

/// Pantalla 18 de Figma: gestion de postulantes, del lado del lider.
class ApplicantsPage extends StatefulWidget {
  const ApplicantsPage({super.key});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  /// Los postulantes se piden una sola vez, y solo cuando ya se sabe que quien
  /// mira es el lider.
  bool _cargaPedida = false;

  /// El perfil de quien tiene la sesion, o null mientras no haya cargado. Leerlo
  /// dentro de un `Obx` repinta la pantalla cuando llegue.
  Profile? _profile() => Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>().profile
      : null;

  /// Aceptar suma un miembro y cerrar el reclutamiento cambia el proyecto: la
  /// cartelera y el detalle guardan su propia copia, y sin esto seguirian
  /// mostrando el contador de antes.
  void _refrescarProyectos() {
    if (Get.isRegistered<ProjectController>()) {
      Get.find<ProjectController>().getProjects();
    }
  }

  Future<void> _decidir(
    ManagementController controller,
    String applicationId,
    ApplicationStatus decision,
  ) async {
    await controller.decide(applicationId, decision);
    _refrescarProyectos();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }

  Future<void> _confirmCloseRecruitment(
    BuildContext context,
    ManagementController controller,
    String projectId,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radius * 3),
        ),
        side: BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
      ),
      builder: (sheetContext) {
        final TextTheme textTheme = Theme.of(sheetContext).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.gapL,
              vertical: AppTokens.gapXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '¿Cerrar el reclutamiento?',
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.gapM),
                Text(
                  'El proyecto dejará de recibir postulaciones nuevas.',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.gapXl),
                ElevatedButton(
                  onPressed: () async {
                    await controller.closeRecruitment(projectId);
                    _refrescarProyectos();
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  child: const Text('Sí, cerrar reclutamiento'),
                ),
                const SizedBox(height: AppTokens.gapS),
                OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplicantCard(BuildContext context, Application application) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final controller = Get.find<ManagementController>();

    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.paper,
                child: Text(
                  _initials(application.applicantName),
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.gapM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicantName,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.gapXs),
                    Text(
                      '${application.applicantProgram} · '
                      '${application.applicantSemester}.º semestre',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!application.isPending)
                Pill(
                  label: _statusLabel(application.status),
                  background: application.status == ApplicationStatus.accepted
                      ? AppColors.petrol
                      : AppColors.card,
                  foreground: application.status == ApplicationStatus.accepted
                      ? Colors.white
                      : null,
                ),
            ],
          ),
          if (application.skillsOffered.isNotEmpty) ...[
            const SizedBox(height: AppTokens.gapM),
            Wrap(
              spacing: AppTokens.gapS,
              runSpacing: AppTokens.gapS,
              children: application.skillsOffered
                  .map((s) => Pill(label: s, background: AppColors.paper))
                  .toList(),
            ),
          ],
          if (application.isPending) ...[
            const SizedBox(height: AppTokens.gapM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _decidir(
                      controller,
                      application.id ?? '',
                      ApplicationStatus.rejected,
                    ),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: AppTokens.gapM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _decidir(
                      controller,
                      application.id ?? '',
                      ApplicationStatus.accepted,
                    ),
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return 'Aceptada';
      case ApplicationStatus.rejected:
        return 'Rechazada';
      case ApplicationStatus.withdrawn:
        return 'Cancelada';
      case ApplicationStatus.left:
        return 'Salió';
      case ApplicationStatus.removed:
        return 'Removido';
      case ApplicationStatus.pending:
        return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Project? project =
        Get.arguments is Project ? Get.arguments as Project : null;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gestión de postulantes')),
        body: const Center(
          child: Text('Get.arguments llegó vacío: se esperaba un Project.'),
        ),
      );
    }

    final controller = Get.find<ManagementController>();
    final String projectId = project.id ?? '';

    // El permiso depende del perfil, que puede llegar despues de abrir la
    // pantalla: por eso todo va dentro de un Obx.
    return Obx(() {
      final Profile? profile = _profile();

      if (profile?.id == null) {
        final bool cargando = Get.isRegistered<ProfileController>() &&
            Get.find<ProfileController>().isLoading.value;
        return Scaffold(
          appBar: AppBar(title: const Text('Gestión de postulantes')),
          body: Center(
            child: cargando
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(AppTokens.gapL),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'No pudimos comprobar quién eres.',
                          textAlign: TextAlign.center,
                        ),
                        if (Get.isRegistered<ProfileController>()) ...[
                          const SizedBox(height: AppTokens.gapM),
                          ElevatedButton(
                            onPressed: () => Get.find<ProfileController>()
                                .getCurrentProfile(),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        );
      }

      if (project.leaderId != profile!.id) {
        return Scaffold(
          appBar: AppBar(title: const Text('Gestión de postulantes')),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTokens.gapL),
              child: Text(
                'No tienes permiso para gestionar los postulantes de este '
                'proyecto: solo el líder puede hacerlo.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      if (!_cargaPedida) {
        _cargaPedida = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.getApplicants(projectId);
        });
      }

      return Scaffold(
      appBar: AppBar(title: const Text('Gestión de postulantes')),
      body: Obx(() {
        // El spinner a pantalla completa es solo para cuando aun no hay nada
        // que enseñar: al aceptar o refrescar, la lista se queda como esta.
        if (controller.isLoading.value && controller.project == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final Project current = controller.project ?? project;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTokens.gapL),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${controller.pendingCount} postulaciones pendientes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.getApplicants(projectId),
                child: controller.applicants.isEmpty
                    // Scrollable aunque este vacia, para poder deslizar.
                    ? LayoutBuilder(
                        builder: (context, constraints) => ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: constraints.maxHeight,
                              child: const Center(
                                child: Text('Todavía no hay postulantes.'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: AppTokens.gapL),
                        children: [
                          for (final application in controller.applicants)
                            _buildApplicantCard(context, application),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTokens.gapL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: current.recruitmentOpen
                        ? () => _confirmCloseRecruitment(
                              context,
                              controller,
                              projectId,
                            )
                        : null,
                    child: Text(
                      current.recruitmentOpen
                          ? 'Cerrar reclutamiento'
                          : 'Reclutamiento cerrado',
                    ),
                  ),
                  const SizedBox(height: AppTokens.gapS),
                  Text(
                    current.recruitmentOpen
                        ? 'El proyecto dejará de recibir postulaciones nuevas.'
                        : 'El proyecto ya no recibe postulaciones nuevas.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
    });
  }
}
