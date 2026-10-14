import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/app_routes.dart';
import 'package:f_clean_template/core/app_tokens.dart';
import 'package:f_clean_template/features/showcase/ui/viewmodels/showcase_controller.dart';

class ShowcaseBanner extends StatelessWidget {
  const ShowcaseBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final showcaseCtrl = Get.isRegistered<ShowcaseController>()
        ? Get.find<ShowcaseController>()
        : null;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppTokens.gapL,
        right: AppTokens.gapL + AppTokens.shadowOffset,
        top: AppTokens.gapS,
        bottom: AppTokens.gapM + AppTokens.shadowOffset,
      ),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.showcase),
        borderRadius: AppTokens.borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.gapL,
            vertical: AppTokens.gapM + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.petrol,
            borderRadius: AppTokens.borderRadius,
            border: AppTokens.border(),
            boxShadow: AppTokens.hardShadow(),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prototipos abiertos a comentarios',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppTokens.gapXs),
                    if (showcaseCtrl != null)
                      Obx(() {
                        final count = showcaseCtrl.prototypeProjects.length;
                        final label = count == 1
                            ? '1 proyecto espera tu retroalimentación'
                            : '$count proyectos esperan tu retroalimentación';
                        return Text(
                          label,
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFD3E7E3),
                          ),
                        );
                      })
                    else
                      Text(
                        'Proyectos esperan tu retroalimentación',
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFD3E7E3),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.gapS),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
