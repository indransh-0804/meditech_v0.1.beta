import 'package:flutter/material.dart';
import 'package:meditech_v1/core/core.dart';

class Header extends StatelessWidget {
  final String header;
  const Header({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: SizeConfig.h(8)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
          child: Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Text(
              header,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
      ],
    );
  }
}
