import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final String role;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.role,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 201),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 1.4),
            width: selected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 37,
              color: selected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 13),
            Text(
              role,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
