import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_tokens.dart';
import '../../viewmodels/profile_controller.dart';

class ProfileSkillsLine extends StatelessWidget {
  const ProfileSkillsLine({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return Obx(() {
      final profile = controller.profile;
      if (profile == null) return const SizedBox.shrink();
      if (profile.skills.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.gapL,
          AppTokens.gapM,
          AppTokens.gapL,
          AppTokens.gapS,
        ),
        child: Text(
          'Proyectos que buscan: ${profile.skills.join(" · ")}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondary,
              ),
        ),
      );
    });
  }
}
