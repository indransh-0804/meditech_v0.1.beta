import 'package:flutter/material.dart';
import 'package:meditech_v1/core/core.dart';

class InfoTile extends StatelessWidget {
  final InfoTileData data;

  const InfoTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(4)),
        padding: EdgeInsets.all(SizeConfig.w(16)),
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(SizeConfig.w(16)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(data.icon, color: data.iconColor, size: SizeConfig.w(24)),
                SizedBox(width: SizeConfig.w(16)),
                Text(
                  data.value,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.h(8)),
            Text(
              data.label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- OverviewRow --------------------
class OverviewRow extends StatelessWidget {
  final OverviewRowData data;

  const OverviewRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(SizeConfig.w(16)),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.w(8)),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SizeConfig.w(8)),
            ),
            child: Icon(data.icon, color: data.color, size: SizeConfig.w(20)),
          ),
          SizedBox(width: SizeConfig.w(16)),
          Expanded(
            child: Text(
              data.label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            data.value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }
}
