import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/app_tokens.dart';
import '../../../my_projects/ui/views/my_projects_view.dart';
import '../../../profile/ui/views/profile_view.dart';
import 'cartelera_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      Get.toNamed(AppRoutes.createIdea);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          CarteleraView(),
          MyProjectsView(),
          SizedBox.shrink(), // Index 2 is "Crear", which opens a new route
          _NotificationsEmptyView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _NotificationsEmptyView extends StatelessWidget {
  const _NotificationsEmptyView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.gapXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_none, size: 48, color: AppColors.secondary),
              const SizedBox(height: AppTokens.gapM),
              Text(
                'Todavía no tienes notificaciones',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.ink, width: AppTokens.borderWidth)),
      ),
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NavBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Inicio',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            icon: Icons.folder_outlined,
            activeIcon: Icons.folder,
            label: 'Mis proyectos',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _CreateActionItem(),
          _NavBarItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: 'Notificaciones',
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Perfil',
            isActive: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: AppColors.ink),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: 16,
              decoration: BoxDecoration(
                color: isActive ? AppColors.persimmon : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateActionItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.createIdea),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: AppTokens.borderRadius,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              'Crear',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
}
