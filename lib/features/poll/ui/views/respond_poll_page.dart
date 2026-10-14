import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/app_tokens.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../domain/models/poll.dart';
import '../../domain/models/poll_response.dart';
import '../viewmodels/poll_controller.dart';

class RespondPollPage extends StatefulWidget {
  const RespondPollPage({super.key});

  @override
  State<RespondPollPage> createState() => _RespondPollPageState();
}

class _RespondPollPageState extends State<RespondPollPage> {
  final _commentCtrl = TextEditingController();
  final List<int?> _answers = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final Poll poll = Get.arguments as Poll;
    _answers.assignAll(List.filled(poll.questions.length, null));
  }

  Future<void> _sendResponse(Poll poll) async {
    if (_answers.any((a) => a == null)) {
      Get.snackbar('Error', 'Debes responder todas las preguntas');
      return;
    }

    setState(() => _isSending = true);

    final controller = Get.find<PollController>();
    final authRepo = Get.find<IAuthRepository>();
    final user = await authRepo.getLoggedUser();

    if (user == null) {
      setState(() => _isSending = false);
      return;
    }

    final response = PollResponse(
      pollId: poll.id!,
      respondentId: user.id!,
      answers: _answers.cast<int>(),
      comment: _commentCtrl.text.trim(),
    );

    final created = await controller.respondPoll(response);
    setState(() => _isSending = false);

    if (created != null) {
      Get.offNamed(AppRoutes.pollResults, arguments: poll);
    } else {
      Get.snackbar('Error', 'No se pudo enviar la respuesta');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Poll poll = Get.arguments as Poll;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(poll.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.gapL),
        children: [
          if (poll.description.isNotEmpty) ...[
            Text(poll.description, style: theme.textTheme.bodyLarge),
            const SizedBox(height: AppTokens.gapXl),
          ],
          for (int i = 0; i < poll.questions.length; i++) ...[
            Text(
              '${i + 1}. ${poll.questions[i].text}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.gapS),
            for (int j = 0; j < poll.questions[i].options.length; j++)
              RadioListTile<int>(
                value: j,
                groupValue: _answers[i],
                onChanged: (v) => setState(() => _answers[i] = v),
                title: Text(poll.questions[i].options[j]),
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: AppTokens.gapM),
          ],
          const SizedBox(height: AppTokens.gapXl),
          TextField(
            controller: _commentCtrl,
            decoration: const InputDecoration(
              labelText: '¿Por qué elegiste estas opciones? (Opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppTokens.gapXl * 2),
          ElevatedButton(
            onPressed: _isSending ? null : () => _sendResponse(poll),
            child: _isSending
                ? const CircularProgressIndicator()
                : const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
