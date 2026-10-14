import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_catalogs.dart';
import '../../../../core/app_tokens.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../project/domain/models/project.dart';
import '../../domain/models/poll.dart';
import '../viewmodels/poll_controller.dart';

class _QuestionData {
  String text = '';
  List<String> options = ['', ''];
}

class CreatePollPage extends StatefulWidget {
  const CreatePollPage({super.key});

  @override
  State<CreatePollPage> createState() => _CreatePollPageState();
}

class _CreatePollPageState extends State<CreatePollPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  DateTime? _closesAt;
  String? _audienceProgram;
  
  final List<_QuestionData> _questions = [_QuestionData()];
  bool _isPublishing = false;

  void _addQuestion() {
    setState(() => _questions.add(_QuestionData()));
  }

  void _removeQuestion(int index) {
    setState(() => _questions.removeAt(index));
  }

  void _addOption(int qIndex) {
    setState(() => _questions[qIndex].options.add(''));
  }

  void _removeOption(int qIndex, int oIndex) {
    setState(() => _questions[qIndex].options.removeAt(oIndex));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _closesAt = date);
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_closesAt == null) {
      Get.snackbar('Error', 'Debes seleccionar una fecha de cierre');
      return;
    }
    
    // Ensure all options are filled
    for (var q in _questions) {
      if (q.options.any((o) => o.trim().isEmpty)) {
        Get.snackbar('Error', 'Todas las opciones deben tener texto');
        return;
      }
      if (q.options.length < 2) {
        Get.snackbar('Error', 'Cada pregunta debe tener al menos 2 opciones');
        return;
      }
    }

    setState(() => _isPublishing = true);
    
    final Project project = Get.arguments as Project;
    final pollController = Get.find<PollController>();
    final authRepo = Get.find<IAuthRepository>();
    final user = await authRepo.getLoggedUser();
    
    if (user == null) {
      setState(() => _isPublishing = false);
      return;
    }

    final poll = Poll(
      projectId: project.id!,
      authorId: user.id!,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      closesAt: _closesAt!,
      audienceProgram: _audienceProgram,
      questions: _questions.map((q) => PollQuestion(
        text: q.text.trim(),
        options: q.options.map((o) => o.trim()).toList(),
      )).toList(),
    );

    final created = await pollController.createPoll(poll);
    setState(() => _isPublishing = false);
    
    if (created != null) {
      Get.back(result: true);
    } else {
      Get.snackbar('Error', 'No se pudo crear la encuesta');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Encuesta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.gapL),
          children: [
            Text('Detalles', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.gapM),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
              validator: (v) => v?.trim().isEmpty == true ? 'Requerido' : null,
            ),
            const SizedBox(height: AppTokens.gapM),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
              maxLines: 3,
              validator: (v) => v?.trim().isEmpty == true ? 'Requerido' : null,
            ),
            const SizedBox(height: AppTokens.gapM),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de cierre'),
              subtitle: Text(_closesAt == null ? 'Seleccionar fecha futura' : '${_closesAt!.day}/${_closesAt!.month}/${_closesAt!.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: AppTokens.gapM),
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(labelText: 'Audiencia (Opcional)', border: OutlineInputBorder()),
              value: _audienceProgram,
              items: [
                const DropdownMenuItem(value: null, child: Text('Toda la comunidad')),
                ...AppCatalogs.academicPrograms.map((p) => DropdownMenuItem(value: p, child: Text(p))),
              ],
              onChanged: (v) => setState(() => _audienceProgram = v),
            ),
            const SizedBox(height: AppTokens.gapXl),
            Text('Preguntas', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.gapM),
            
            for (int i = 0; i < _questions.length; i++) ...[
              Card(
                margin: const EdgeInsets.only(bottom: AppTokens.gapL),
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.gapM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _questions[i].text,
                              decoration: InputDecoration(labelText: 'Pregunta ${i + 1}'),
                              onChanged: (v) => _questions[i].text = v,
                              validator: (v) => v?.trim().isEmpty == true ? 'Requerido' : null,
                            ),
                          ),
                          if (_questions.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.persimmon),
                              onPressed: () => _removeQuestion(i),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.gapM),
                      for (int j = 0; j < _questions[i].options.length; j++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppTokens.gapS),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _questions[i].options[j],
                                  decoration: InputDecoration(
                                    labelText: 'Opción ${j + 1}',
                                    isDense: true,
                                  ),
                                  onChanged: (v) => _questions[i].options[j] = v,
                                ),
                              ),
                              if (_questions[i].options.length > 2)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _removeOption(i, j),
                                ),
                            ],
                          ),
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir opción'),
                        onPressed: () => _addOption(i),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Añadir pregunta'),
              onPressed: _addQuestion,
            ),
            const SizedBox(height: AppTokens.gapXl * 2),
            ElevatedButton(
              onPressed: _isPublishing ? null : _publish,
              child: _isPublishing 
                  ? const CircularProgressIndicator() 
                  : const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
