import 'package:flutter/material.dart';

import 'package:f_clean_template/core/app_tokens.dart';
import 'package:f_clean_template/features/showcase/domain/models/project_comment.dart';

class CommentThreadView extends StatelessWidget {
  const CommentThreadView({
    super.key,
    required this.comment,
    required this.replies,
    required this.canReply,
    required this.onReplyTap,
  });

  final ProjectComment comment;
  final List<ProjectComment> replies;
  final bool canReply;
  final VoidCallback onReplyTap;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }

  Color _avatarColor(String name) {
    final colors = [
      AppStageColors.testing,
      AppColors.petrol,
      AppColors.persimmon,
      AppStageColors.research,
      AppColors.ink,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  Widget _commentBody({
    required BuildContext context,
    required ProjectComment item,
    required bool isReply,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _avatarColor(item.authorName),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(item.authorName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: AppTokens.gapS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.authorName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.isTeam)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'EQUIPO DEL PROYECTO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!isReply && canReply)
              TextButton(
                onPressed: onReplyTap,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Responder',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.persimmon,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTokens.gapS),
        Text(
          item.text,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.gapL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _commentBody(
            context: context,
            item: comment,
            isReply: false,
          ),
          if (replies.isNotEmpty) ...[
            const SizedBox(height: AppTokens.gapM),
            for (final reply in replies)
              Container(
                margin: const EdgeInsets.only(
                  left: AppTokens.gapL,
                  bottom: AppTokens.gapM,
                ),
                padding: const EdgeInsets.only(left: AppTokens.gapM),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.ink,
                      width: 2.0,
                    ),
                  ),
                ),
                child: _commentBody(
                  context: context,
                  item: reply,
                  isReply: true,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
