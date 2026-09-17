import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../../core/app_catalogs.dart';
import '../../../../core/app_routes.dart';
import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/paper_card.dart';
import '../../../../core/widgets/pill.dart';
import '../../../profile/ui/viewmodels/profile_controller.dart';
import '../../domain/models/project.dart';
import '../viewmodels/project_controller.dart';
import 'widgets/stage_chip.dart';

class CreateIdeaPage extends StatefulWidget {
  const CreateIdeaPage({super.key});

  @override
  State<CreateIdeaPage> createState() => _CreateIdeaPageState();
}

class _CreateIdeaPageState extends State<CreateIdeaPage> with UiLoggy {
  final _titleController = TextEditingController();
  final _problemController = TextEditingController();
  final _descriptionController = TextEditingController();

  ProjectStage? _selectedStage;
  int _maxMembers = 2; // minimum is 2 since leader is 1
  final List<String> _skillsWanted = [];
  final List<String> _tags = [];

  final _profileController = Get.find<ProfileController>();
  final _projectController = Get.find<ProjectController>();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateState);
    _problemController.addListener(_updateState);
    _descriptionController.addListener(_updateState);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _problemController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  int get _completedRequiredFieldsCount {
    int count = 0;
    if (_titleController.text.trim().isNotEmpty) count++;
    if (_problemController.text.trim().isNotEmpty) count++;
    if (_descriptionController.text.trim().isNotEmpty) count++;
    if (_selectedStage != null) count++;
    if (_profileController.profile?.academicProgram != null) count++;
    if (_skillsWanted.isNotEmpty) count++;
    return count;
  }

  /// Sin un id de perfil utilizable no se puede publicar: el proyecto naceria
  /// sin lider y su autor no podria gestionar los postulantes de su propia idea.
  bool get _hasValidLeader {
    final id = _profileController.profile?.id;
    return id != null && id.isNotEmpty;
  }

  bool get _canPublish => _completedRequiredFieldsCount == 6 && _hasValidLeader;

  Future<void> _publish() async {
    if (!_canPublish) return;

    final profile = _profileController.profile;
    if (profile == null) {
      loggy.error('No se encontro el perfil activo');
      return;
    }

    final leaderId = profile.id;
    if (leaderId == null || leaderId.isEmpty) {
      loggy.error('El perfil activo no tiene id: la idea nacería sin líder');
      return;
    }

    final project = Project(
      title: _titleController.text.trim(),
      problem: _problemController.text.trim(),
      description: _descriptionController.text.trim(),
      stage: _selectedStage!,
      academicProgram: profile.academicProgram,
      currentMembers: 1, // el lider
      maxMembers: _maxMembers,
      skillsWanted: List.from(_skillsWanted),
      tags: List.from(_tags),
      leaderId: leaderId,
      recruitmentOpen: true,
    );

    final createdProject = await _projectController.createProject(project);
    Get.offAndToNamed(AppRoutes.ideaPublished, arguments: createdProject);
  }

  /// Marcar y desmarcar sobre la misma lista. Con un catalogo cerrado no hay
  /// nada que validar: el valor solo puede salir de [AppCatalogs].
  void _toggle(List<String> seleccion, String valor) {
    setState(() {
      if (seleccion.contains(valor)) {
        seleccion.remove(valor);
      } else {
        seleccion.add(valor);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Nueva idea de proyecto'),
        backgroundColor: AppColors.paper,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.gapXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressHeader(),
            const SizedBox(height: AppTokens.gapXl),
            
            // Section 1: Lo esencial
            _buildSectionHeader('01 · Lo esencial'),
            const SizedBox(height: AppTokens.gapM),
            _buildTextField(
              controller: _titleController,
              label: 'Título del proyecto',
              hint: 'Ej: App de movilidad sostenible para el campus',
            ),
            const SizedBox(height: AppTokens.gapM),
            _buildTextField(
              controller: _problemController,
              label: 'Problema a resolver',
              hint: '¿Qué situación quieres mejorar o resolver?',
              maxLines: 3,
            ),
            const SizedBox(height: AppTokens.gapM),
            _buildTextField(
              controller: _descriptionController,
              label: 'Descripción',
              hint: 'Cuenta cómo funcionaría y qué ya tienes hecho.',
              maxLines: 4,
            ),
            const SizedBox(height: AppTokens.gapXl),

            // Section 2: El equipo que buscas
            _buildSectionHeader('02 · El equipo que buscas'),
            const SizedBox(height: AppTokens.gapM),
            _buildSkillsInput(),
            const SizedBox(height: AppTokens.gapL),
            _buildMembersStepper(),
            const SizedBox(height: AppTokens.gapL),
            _buildStageSelector(),
            const SizedBox(height: AppTokens.gapXl),

            // Section 3: Dale contexto (opcional)
            _buildSectionHeader('03 · Dale contexto · opcional'),
            const SizedBox(height: AppTokens.gapM),
            _buildTagsInput(),
            const SizedBox(height: AppTokens.gapL),
            _buildImageDropzone(),
            const SizedBox(height: AppTokens.gapXl * 2),

            // Botones de accion
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO(carril idea): Guardar borrador (no hace nada todavia)
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTokens.borderRadius,
                      ),
                    ),
                    child: const Text('Guardar borrador'),
                  ),
                ),
                const SizedBox(width: AppTokens.gapM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canPublish ? _publish : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.persimmon,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTokens.borderRadius,
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Publicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return PaperCard(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.gapM),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$_completedRequiredFieldsCount de 6 campos obligatorios',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            CircularProgressIndicator(
              value: _completedRequiredFieldsCount / 6,
              backgroundColor: AppColors.paper,
              color: AppColors.persimmon,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: AppTokens.borderRadius,
          borderSide: const BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadius,
          borderSide: const BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
        ),
        filled: true,
        fillColor: AppColors.card,
      ),
    );
  }

  /// Chip pulsable de seleccion. Marcado y sin marcar se distinguen por el
  /// fondo, no solo por el borde.
  Widget _selectableChip({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Pill(
        label: label,
        background: selected ? selectedColor : AppColors.card,
      ),
    );
  }

  Widget _buildChipGroup({
    required String label,
    required List<String> options,
    required List<String> selection,
    required Color selectedColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppTokens.gapS),
        Wrap(
          spacing: AppTokens.gapS,
          runSpacing: AppTokens.gapS,
          children: [
            for (final option in options)
              _selectableChip(
                label: option,
                selected: selection.contains(option),
                selectedColor: selectedColor,
                onTap: () => _toggle(selection, option),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsInput() => _buildChipGroup(
        label: 'Habilidades requeridas',
        options: AppCatalogs.skills,
        selection: _skillsWanted,
        selectedColor: AppColors.persimmon,
      );

  Widget _buildMembersStepper() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Personas en el equipo',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: AppTokens.border(),
            borderRadius: AppTokens.borderRadius,
            color: AppColors.card,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _maxMembers > 2
                    ? () => setState(() => _maxMembers--)
                    : null,
              ),
              Text(
                '$_maxMembers',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _maxMembers++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etapa actual',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppTokens.gapS),
        Wrap(
          spacing: AppTokens.gapS,
          runSpacing: AppTokens.gapS,
          children: [
            // Seleccion unica: tocar otra reemplaza la marcada. La marcada se
            // pinta con el color de su etapa, que lo da StageChip.
            for (final stage in ProjectStage.values)
              _selectableChip(
                label: StageChip.labelOf(stage),
                selected: _selectedStage == stage,
                selectedColor: StageChip.colorOf(stage),
                onTap: () => setState(() => _selectedStage = stage),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsInput() => _buildChipGroup(
        label: 'Tags del proyecto',
        options: AppCatalogs.tags,
        selection: _tags,
        selectedColor: AppColors.petrol,
      );

  Widget _buildImageDropzone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.gapXl),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.ink, width: AppTokens.borderWidth, style: BorderStyle.solid),
        borderRadius: AppTokens.borderRadius,
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.secondary),
          const SizedBox(height: AppTokens.gapS),
          Text(
            'Arrastra imágenes o toca para subir',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),
          // TODO(carril idea): funcionalidad de imagenes no requerida en esta semana
        ],
      ),
    );
  }
}
