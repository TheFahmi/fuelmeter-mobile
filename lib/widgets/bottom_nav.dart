import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  int _indexFromLocation(String loc) {
    if (loc == '/' || loc.startsWith('/auth-gate')) return 0;
    if (loc.startsWith('/stats')) return 1;
    if (loc.startsWith('/records')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  void _go(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/stats');
        break;
      case 2:
        context.go('/records');
        break;
      case 3:
        context.go('/profile');
        break;
      default:
        context.go('/');
    }
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(color: color, fontSize: 12, height: 1.1)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final current = _indexFromLocation(loc);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 76,
        elevation: 0,
        color: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _item(context,
                      icon: Icons.home_outlined,
                      label: 'Home',
                      selected: current == 0,
                      onTap: () => _go(context, 0)),
                  _item(context,
                      icon: Icons.bar_chart_outlined,
                      label: 'Stats',
                      selected: current == 1,
                      onTap: () => _go(context, 1)),
                ],
              ),
            ),
            const SizedBox(width: 64),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _item(context,
                      icon: Icons.list_alt_outlined,
                      label: 'Records',
                      selected: current == 2,
                      onTap: () => _go(context, 2)),
                  _item(context,
                      icon: Icons.person_outline,
                      label: 'Profile',
                      selected: current == 3,
                      onTap: () => _go(context, 3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
