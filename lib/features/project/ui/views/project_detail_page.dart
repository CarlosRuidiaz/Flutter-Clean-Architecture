import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/pill.dart';
import '../../../application/domain/models/application.dart';
import '../../../application/domain/repositories/i_application_repository.dart';
import '../../../application/ui/viewmodels/application_controller.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../profile/ui/viewmodels/profile_controller.dart';
import '../../domain/models/project.dart';
import '../viewmodels/project_controller.dart';
import 'widgets/stage_chip.dart';
import '../../../follow/ui/viewmodels/follow_controller.dart';
import '../../../poll/ui/views/widgets/active_polls_block.dart';

/// Pantalla 07 de Figma: Detalle de un proyecto con el flujo de postulación.
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key});

  /// Las dos primeras iniciales de un nombre completo.
  String _initials(String name) {
    final partes = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letras = partes.take(2).map((p) => p[0].toUpperCase()).join();
    return letras.isEmpty ? '?' : letras;
  }

  /// Nombre corto para la linea bajo los avatares: "Carlos R.". Un nombre sin
  /// apellido (el marcador del lider desconocido) se deja tal cual.
  String _shortName(String name) {
    final partes = name.trim().split(RegExp(r'\s+'));
    if (partes.length != 2) return name;
    return '${partes[0]} ${partes[1][0].toUpperCase()}.';
  }

  Widget _buildTeamAvatars(
    BuildContext context,
    List<String> initialsList,
    String namesLine,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final iniciales in initialsList) ...[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: AppTokens.border(),
                ),
                alignment: Alignment.center,
                child: Text(
                  iniciales,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.gapS),
            ],
          ],
        ),
        const SizedBox(height: AppTokens.gapS),
        Text(namesLine, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  /// El perfil de quien tiene la sesión, o null mientras no haya cargado. Leerlo
  /// dentro de un `Obx` hace que la pantalla se repinte cuando llegue.
  Profile? _profile() => Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>().profile
      : null;

  /// El estudiante en sesión, o null si su perfil todavía no cargó. Sin id no
  /// se adivina nadie: ya hubo postulaciones a nombre de otra persona.
  String? _applicantId() => _profile()?.id;

  /// Pide el perfil si todavía no está, y con él las postulaciones del
  /// estudiante (para saber si ya se postuló, si lo removieron o si es
  /// miembro) y los proyectos al día.
  Future<void> _cargar(ProjectController projectController) async {
    String? id = _applicantId();
    if (id == null && Get.isRegistered<ProfileController>()) {
      await Get.find<ProfileController>().getCurrentProfile();
      id = _applicantId();
    }
    if (id != null) {
      await Get.find<ApplicationController>().getMyApplications(id);
    }
    await projectController.getProjects();
  }

  Widget _buildFooterButtons(BuildContext context, Project project) {
    final controller = Get.find<ApplicationController>();
    final followController = Get.isRegistered<FollowController>() ? Get.find<FollowController>() : null;
    final String applicantId = _applicantId();
    final bool esLider = project.leaderId == applicantId;

    return Obx(() {
      final profile = _profile();

      // Si ya hay una postulación viva a este proyecto, la pantalla 07 lleva a
      // verla en vez de ofrecer postularse otra vez. Es la única entrada a la
      // pantalla 19 mientras la 18 no exista, y evita duplicados.
      final vigente = controller.vigenteEn(project.id ?? '');
      final bool removido = controller.fueRemovidoDe(project.id ?? '');
      final bool isFollowing = followController?.isFollowing(project.id ?? '') ?? false;

      return Row(
        children: [
          if (!esLider)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (project.id != null) {
                    followController?.toggleFollow(project.id!, !isFollowing);
                  }
                },
                child: Text(isFollowing ? 'Siguiendo' : 'Seguir'),
              ),
            ),
          if (vigente != null) ...[
            const SizedBox(width: AppTokens.gapM),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.applicationStatus,
                  arguments: vigente,
                ),
                child: const Text('Ver mi postulación'),
              ),
            ),
          ] else if (removido) ...[
            // El líder lo sacó: no vuelve a postularse a este proyecto.
            const SizedBox(width: AppTokens.gapM),
            Expanded(
              child: Text(
                'Te removieron de este proyecto.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ] else if (project.acceptsApplicationsFrom(profile?.id)) ...[
            const SizedBox(width: AppTokens.gapM),
            Expanded(
              child: ElevatedButton(
                // Sin perfil cargado el botón se ve deshabilitado: postularse
                // ahora sería hacerlo a nombre de nadie.
                onPressed: profile?.id == null
                    ? null
                    : () async {
                        final application = Application(
                          projectId: project.id ?? '',
                          applicantId: profile!.id!,
                          applicantName: profile.fullName,
                          applicantProgram: profile.academicProgram,
                          applicantSemester: profile.semester,
                          skillsOffered: profile.skills,
                          status: ApplicationStatus.pending,
                        );
                        final created = await controller.apply(application);
                        if (created != null) {
                          Get.toNamed(
                            AppRoutes.applicationStatus,
                            arguments: created,
                          );
                        }
                      },
                child: const Text('Postularme'),
              ),
            ),
          ],
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Project? argumento = Get.arguments is Project
        ? Get.arguments as Project
        : null;

    if (argumento == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(
          child: Text('Get.arguments llegó vacío: se esperaba un Project.'),
        ),
      );
    }

    final TextTheme textTheme = Theme.of(context).textTheme;

    // Al abrir el detalle hay que saber en qué quedó la postulación a este
    // proyecto (el líder pudo aceptarla o removerlo desde la última vez), y
    // ademas releer el proyecto: pudo cambiar su numero de miembros o su etapa.
    // Va despues del primer frame para no cambiar un Rx durante build.
    final ProjectController projectController = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargar(projectController);
    });

    return Scaffold(
      appBar: AppBar(title: Text(argumento.title)),
      body: Obx(() {
        // El proyecto del argumento es la foto que tenia la cartelera al
        // abrirlo. La copia viva es la del controlador: por eso se prefiere
        // esa, y el argumento queda solo de respaldo.
        final Project project =
            projectController.projects.firstWhereOrNull(
              (p) => p.id == argumento.id,
            ) ??
            argumento;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.gapL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: Etapa + tags del proyecto
              Wrap(
                spacing: AppTokens.gapS,
                runSpacing: AppTokens.gapXs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StageChip(stage: project.stage),
                  for (final tag in project.tags)
                    Pill(label: tag, background: AppColors.card),
                ],
              ),
              const SizedBox(height: AppTokens.gapM),

              // Título del proyecto y programa académico
              Text(project.title, style: textTheme.headlineMedium),
              const SizedBox(height: AppTokens.gapXs),
              Text(project.academicProgram, style: textTheme.bodySmall),
              const SizedBox(height: AppTokens.gapM),

              // Contador de miembros
              Text(
                '${project.currentMembers} de ${project.maxMembers} miembros',
                style: textTheme.bodyMedium?.copyWith(
                  color: project.isFull ? AppColors.persimmon : AppColors.ink,
                  fontWeight: project.isFull
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: AppTokens.gapL),

              // Problema a resolver (si existe)
              if (project.problem.isNotEmpty) ...[
                Text('Problema a resolver', style: textTheme.titleMedium),
                const SizedBox(height: AppTokens.gapS),
                Text(project.problem, style: textTheme.bodyLarge),
                const SizedBox(height: AppTokens.gapL),
              ],

              // Descripción
              Text('Descripción', style: textTheme.titleMedium),
              const SizedBox(height: AppTokens.gapS),
              Text(project.description, style: textTheme.bodyLarge),
              const SizedBox(height: AppTokens.gapL),

              // Habilidades requeridas
              Text('Habilidades requeridas', style: textTheme.titleMedium),
              const SizedBox(height: AppTokens.gapS),
              if (project.skillsWanted.isNotEmpty)
                Wrap(
                  spacing: AppTokens.gapS,
                  runSpacing: AppTokens.gapS,
                  children: project.skillsWanted
                      .map((s) => Pill(label: s, background: AppColors.card))
                      .toList(),
                )
              else
                Text(
                  'No se requieren habilidades específicas',
                  style: textTheme.bodySmall,
                ),
              const SizedBox(height: AppTokens.gapL),

              // Equipo actual: el lider mas los postulantes aceptados. La
              // misma regla decide quien ve "Gestionar postulantes" y quien
              // ve "Espacio de trabajo".
              FutureBuilder<List<Application>>(
                future: Get.find<IApplicationRepository>().getApplicationsFor(
                  project.id ?? '',
                ),
                builder: (context, snapshot) {
                  final List<Application> aceptados =
                      (snapshot.data ?? const <Application>[])
                          .where((a) => a.status == ApplicationStatus.accepted)
                          .toList();
                  final profile = _profile();
                  final String? applicantId = profile?.id;
                  final bool esLider =
                      applicantId != null && project.leaderId == applicantId;
                  final bool esMiembro =
                      applicantId != null &&
                      aceptados.any((a) => a.applicantId == applicantId);

                  final bool liderEsQuienMira = esLider;
                  final String liderNombre = liderEsQuienMira
                      ? (profile?.fullName ?? 'Líder del proyecto')
                      : 'Líder del proyecto';

                  final List<String> iniciales = [
                    _initials(liderNombre),
                    for (final a in aceptados) _initials(a.applicantName),
                  ];
                  final List<String> nombresCortos = [
                    liderEsQuienMira ? _shortName(liderNombre) : liderNombre,
                    for (final a in aceptados) _shortName(a.applicantName),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Equipo actual', style: textTheme.titleMedium),
                      const SizedBox(height: AppTokens.gapS),
                      _buildTeamAvatars(
                        context,
                        iniciales,
                        nombresCortos.join(' · '),
                      ),
                      const SizedBox(height: AppTokens.gapXl),

                      // Botones del pie
                      _buildFooterButtons(context, project),
                      
                      // Encuestas activas
                      ActivePollsBlock(project: project),

                      // Solo el lider del proyecto gestiona sus postulantes.
                      if (esLider) ...[
                        const SizedBox(height: AppTokens.gapM),
                        OutlinedButton(
                          onPressed: () => Get.toNamed(
                            AppRoutes.applicants,
                            arguments: project,
                          ),
                          child: const Text('Gestionar postulantes'),
                        ),
                      ],

                      // El espacio de trabajo es privado: solo el lider y los
                      // miembros aceptados.
                      if (esLider || esMiembro) ...[
                        const SizedBox(height: AppTokens.gapM),
                        ElevatedButton(
                          onPressed: () => Get.toNamed(
                            AppRoutes.workspace,
                            arguments: project,
                          ),
                          child: const Text('Espacio de trabajo'),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
