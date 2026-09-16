import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

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
  final _skillController = TextEditingController();
  final _tagController = TextEditingController();

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
    _skillController.dispose();
    _tagController.dispose();
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

  bool get _canPublish => _completedRequiredFieldsCount == 6;

  Future<void> _publish() async {
    if (!_canPublish) return;

    final profile = _profileController.profile;
    if (profile == null) {
      loggy.error('No se encontro el perfil activo');
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
      leaderId: profile.id ?? '',
      recruitmentOpen: true,
    );

    final createdProject = await _projectController.createProject(project);
    Get.offAndToNamed(AppRoutes.ideaPublished, arguments: createdProject);
  }

  void _addSkill(String skill) {
    final s = skill.trim();
    if (s.isNotEmpty && !_skillsWanted.contains(s)) {
      setState(() => _skillsWanted.add(s));
    }
    _skillController.clear();
  }

  void _removeSkill(String skill) {
    setState(() => _skillsWanted.remove(skill));
  }

  void _addTag(String tag) {
    final t = tag.trim();
    if (t.isNotEmpty && !_tags.contains(t)) {
      setState(() => _tags.add(t));
    }
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Crear idea'),
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
            ),
            const SizedBox(height: AppTokens.gapM),
            _buildTextField(
              controller: _problemController,
              label: 'Problema a resolver',
              maxLines: 3,
            ),
            const SizedBox(height: AppTokens.gapM),
            _buildTextField(
              controller: _descriptionController,
              label: 'Descripción',
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
                      disabledBackgroundColor: Colors.grey.shade400,
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
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
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSkillsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _skillController,
          onSubmitted: _addSkill,
          decoration: InputDecoration(
            labelText: 'Habilidades buscadas (escribe y presiona Enter)',
            border: OutlineInputBorder(
              borderRadius: AppTokens.borderRadius,
              borderSide: const BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTokens.borderRadius,
              borderSide: const BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        if (_skillsWanted.isNotEmpty) ...[
          const SizedBox(height: AppTokens.gapS),
          Wrap(
            spacing: AppTokens.gapXs,
            runSpacing: AppTokens.gapXs,
            children: _skillsWanted.map((skill) {
              return GestureDetector(
                onTap: () => _removeSkill(skill),
                child: Pill(
                  label: '$skill ✕',
                  background: AppColors.persimmon,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

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
            color: Colors.white,
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
          'Etapa',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppTokens.gapS),
        Wrap(
          spacing: AppTokens.gapXs,
          runSpacing: AppTokens.gapS,
          children: ProjectStage.values.map((stage) {
            final isSelected = _selectedStage == stage;
            return GestureDetector(
              onTap: () => setState(() => _selectedStage = stage),
              child: Opacity(
                opacity: isSelected ? 1.0 : 0.5,
                child: Container(
                  decoration: isSelected 
                    ? BoxDecoration(
                        border: AppTokens.border(),
                        borderRadius: BorderRadius.circular(999),
                      ) 
                    : null,
                  padding: isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
                  child: StageChip(stage: stage),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _tagController,
          onSubmitted: _addTag,
          decoration: InputDecoration(
            labelText: 'Tags (escribe y presiona Enter)',
            border: OutlineInputBorder(
              borderRadius: AppTokens.borderRadius,
              borderSide: const BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTokens.borderRadius,
              borderSide: const BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: AppTokens.gapS),
          Wrap(
            spacing: AppTokens.gapXs,
            runSpacing: AppTokens.gapXs,
            children: _tags.map((tag) {
              return GestureDetector(
                onTap: () => _removeTag(tag),
                child: Pill(
                  label: '$tag ✕',
                  background: AppColors.petrol,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildImageDropzone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.gapXl),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.ink, width: 1, style: BorderStyle.solid),
        borderRadius: AppTokens.borderRadius,
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.secondary),
          const SizedBox(height: AppTokens.gapS),
          Text(
            'Arrastra imágenes aquí o haz clic para subir',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),
          // TODO(carril idea): funcionalidad de imagenes no requerida en esta semana
        ],
      ),
    );
  }
}
