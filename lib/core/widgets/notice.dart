import 'package:flutter/material.dart';
import 'package:meditech_v1/core/utils/size_config.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const InfoCard({super.key, required this.title, this.children = const []});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.w(14)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.info_outlined,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.h(8)),
          ...children,
        ],
      ),
    );
  }
}
