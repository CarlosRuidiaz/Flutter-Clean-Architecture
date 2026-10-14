import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/app_tokens.dart';
import 'package:f_clean_template/core/widgets/pill.dart';
import '../../../project/domain/models/project.dart';
import '../../../project/ui/views/widgets/stage_chip.dart';
import '../viewmodels/showcase_controller.dart';
import 'widgets/comment_thread_view.dart';
import 'widgets/feedback_bottom_sheet.dart';
import 'widgets/feedback_rating_bars.dart';

class PrototypeFeedbackPage extends StatefulWidget {
  const PrototypeFeedbackPage({super.key});

  @override
  State<PrototypeFeedbackPage> createState() => _PrototypeFeedbackPageState();
}

class _PrototypeFeedbackPageState extends State<PrototypeFeedbackPage> {
  final ShowcaseController _controller = Get.find<ShowcaseController>();
  final TextEditingController _commentTextController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  String? _replyToCommentId;
  String? _replyToAuthorName;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final Project? project =
        Get.arguments is Project ? Get.arguments as Project : null;
    if (project != null) {
      _controller.openProject(project);
    }
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _startReply(String commentId, String authorName) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToAuthorName = authorName;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToAuthorName = null;
    });
  }

  Future<void> _handleSendComment() async {
    final text = _commentTextController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final success = await _controller.addComment(
      text,
      parentId: _replyToCommentId,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _commentTextController.clear();
        _cancelReply();
        _commentFocusNode.unfocus();
      }
    }
  }

  void _openFeedbackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FeedbackBottomSheet(
        existingFeedback: _controller.myFeedback,
        onSubmit: ({
          required int usability,
          required int innovation,
          required int visualDesign,
          required int feasibility,
          String? comment,
        }) async {
          await _controller.submitFeedback(
            usability: usability,
            innovation: innovation,
            visualDesign: visualDesign,
            feasibility: feasibility,
            comment: comment,
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, Project project) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      color: AppColors.petrol,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppTokens.gapL,
        left: AppTokens.gapL,
        right: AppTokens.gapL,
        bottom: AppTokens.gapXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: AppTokens.borderRadius,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppTokens.borderRadius,
                border: AppTokens.border(),
                boxShadow: AppTokens.hardShadow(),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.ink,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: AppTokens.gapL),
          Text(
            project.title,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentInputField() {
    return Container(
      padding: EdgeInsets.only(
        left: AppTokens.gapL,
        right: AppTokens.gapL,
        top: AppTokens.gapS,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTokens.gapM,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyToCommentId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.gapXs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Respondiendo a $_replyToAuthorName',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.persimmon,
                    ),
                  ),
                  InkWell(
                    onTap: _cancelReply,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: AppTokens.borderRadius,
                    border: AppTokens.border(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.gapM),
                  child: TextField(
                    controller: _commentTextController,
                    focusNode: _commentFocusNode,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un comentario...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.gapS),
              InkWell(
                onTap: _isSending ? null : _handleSendComment,
                borderRadius: AppTokens.borderRadius,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppTokens.borderRadius,
                    border: AppTokens.border(),
                    boxShadow: AppTokens.hardShadow(),
                  ),
                  alignment: Alignment.center,
                  child: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.persimmon,
                          size: 24,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Obx(() {
        final project = _controller.currentProject.value;
        if (project == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final isTeam = _controller.isTeamMember.value;
        final hasFeedback = _controller.myFeedback != null;
        final roots = _controller.rootComments;

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _controller.refreshDetail,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(context, project),
                      Padding(
                        padding: const EdgeInsets.all(AppTokens.gapL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tags y etapa
                            Wrap(
                              spacing: AppTokens.gapS,
                              runSpacing: AppTokens.gapXs,
                              children: [
                                const StageChip(stage: ProjectStage.prototype),
                                for (final tag in project.tags)
                                  Pill(label: tag, background: AppColors.card),
                              ],
                            ),
                            const SizedBox(height: AppTokens.gapM),

                            // Descripción y problema
                            if (project.description.isNotEmpty) ...[
                              Text(
                                project.description,
                                style: textTheme.bodyLarge,
                              ),
                              const SizedBox(height: AppTokens.gapM),
                            ],
                            if (project.problem.isNotEmpty) ...[
                              Text(
                                'Problema a resolver',
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppTokens.gapXs),
                              Text(
                                project.problem,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: AppTokens.gapL),
                            ],

                            // Sección Retroalimentación
                            const Divider(height: 1),
                            const SizedBox(height: AppTokens.gapL),
                            Text(
                              'RETROALIMENTACIÓN',
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.secondary,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppTokens.gapM),
                            FeedbackRatingBars(
                              summary: _controller.feedbackSummary,
                            ),

                            // Botón de dar feedback (no visible para el equipo)
                            if (!isTeam) ...[
                              const SizedBox(height: AppTokens.gapM),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _openFeedbackSheet(context),
                                  icon: const Icon(Icons.star_outline_rounded),
                                  label: Text(
                                    hasFeedback
                                        ? 'Editar mi retroalimentación'
                                        : 'Dar retroalimentación',
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: AppTokens.gapXl),
                            const Divider(height: 1),
                            const SizedBox(height: AppTokens.gapL),

                            // Sección Comentarios
                            Text(
                              'COMENTARIOS',
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.secondary,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppTokens.gapM),

                            if (roots.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTokens.gapL,
                                ),
                                child: Center(
                                  child: Text(
                                    'Aún no hay comentarios. ¡Sé el primero en comentar!',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.secondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              for (final comment in roots)
                                CommentThreadView(
                                  comment: comment,
                                  replies: _controller.repliesFor(comment.id ?? ''),
                                  canReply: isTeam,
                                  onReplyTap: () => _startReply(
                                    comment.id ?? '',
                                    comment.authorName,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _commentInputField(),
          ],
        );
      }),
    );
  }
}
