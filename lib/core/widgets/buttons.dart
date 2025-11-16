import 'package:flutter/material.dart';
import 'package:meditech_v1/core/utils/size_config.dart';

class FillButton extends StatelessWidget {
  final VoidCallback onPress;
  final String text;
  final bool isLoading;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const FillButton({
    super.key,
    required this.onPress,
    required this.text,
    this.isLoading = false,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FilledButton(
      onPressed: isLoading ? null : onPress,
      style: FilledButton.styleFrom(
        foregroundColor:
            foregroundColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              text,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

class OutButton extends StatelessWidget {
  final VoidCallback onPress;
  final String text;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Widget? child; // new

  const OutButton({
    super.key,
    required this.onPress,
    required this.text,
    this.foregroundColor,
    this.backgroundColor,
    this.child, // new
  });

  OutButton asChild(Widget child) => OutButton(
    onPress: onPress,
    text: text,
    foregroundColor: foregroundColor,
    backgroundColor: backgroundColor,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return OutlinedButton(
      onPressed: onPress,
      style: OutlinedButton.styleFrom(
        foregroundColor:
            foregroundColor ?? Theme.of(context).colorScheme.onSurface,
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.surface,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child:
          child ??
          Text(
            text,
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
    );
  }
}

class HalfActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  final TextTheme textTheme;

  const HalfActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.textTheme,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Color effectiveBackground =
        backgroundColor ?? colorScheme.primaryContainer;
    final Color effectiveIconColor = iconColor ?? colorScheme.primary;
    final Color effectiveTextColor =
        textColor ?? colorScheme.onPrimaryContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig.w(12)),
      child: Container(
        padding: EdgeInsets.all(SizeConfig.w(16)),
        decoration: BoxDecoration(
          color: effectiveBackground,
          borderRadius: BorderRadius.circular(SizeConfig.w(12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(SizeConfig.w(12)),
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SizeConfig.w(10)),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: SizeConfig.w(24),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: effectiveIconColor,
                  size: SizeConfig.w(16),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.h(8)),
            Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                color: effectiveTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: SizeConfig.h(4)),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: effectiveTextColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  final TextTheme textTheme;

  const FullActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.textTheme,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Color effectiveBackground =
        backgroundColor ?? colorScheme.primaryContainer;
    final Color effectiveIconColor = iconColor ?? colorScheme.primary;
    final Color effectiveTextColor =
        textColor ?? colorScheme.onPrimaryContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig.w(12)),
      child: Container(
        padding: EdgeInsets.all(SizeConfig.w(16)),
        decoration: BoxDecoration(
          color: effectiveBackground,
          borderRadius: BorderRadius.circular(SizeConfig.w(12)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.w(12)),
              decoration: BoxDecoration(
                color: effectiveIconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeConfig.w(10)),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: SizeConfig.w(24),
              ),
            ),
            SizedBox(width: SizeConfig.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.titleMedium?.copyWith(
                      color: effectiveTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(4)),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: effectiveTextColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: effectiveIconColor,
              size: SizeConfig.w(16),
            ),
          ],
        ),
      ),
    );
  }
}
