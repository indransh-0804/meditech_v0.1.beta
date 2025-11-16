import 'package:flutter/material.dart';
import 'package:meditech_v1/core/core.dart';

class PasswordRequirement extends StatelessWidget {
  final bool satisfied;
  final String text;

  const PasswordRequirement({
    super.key,
    required this.text,
    this.satisfied = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: satisfied
              ? Icon(
                  Icons.check_circle,
                  key: const ValueKey('ok'),
                  color: Theme.of(context).colorScheme.primary,
                  size: SizeConfig.w(18),
                )
              : Icon(
                  Icons.radio_button_unchecked_outlined,
                  key: const ValueKey('not'),
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: SizeConfig.w(18),
                ),
        ),
        SizedBox(width: SizeConfig.w(8)),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: satisfied
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
