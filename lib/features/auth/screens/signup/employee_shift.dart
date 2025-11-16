import 'package:flutter/material.dart';
import 'package:meditech_v1/core/core.dart';

class EmployeeShiftCard extends StatefulWidget {
  final Function(DateTime)? onClockIn;
  final Function(DateTime)? onClockOut;
  final bool isClocked;
  final DateTime? clockInTime;

  const EmployeeShiftCard({
    super.key,
    this.onClockIn,
    this.onClockOut,
    this.isClocked = false,
    this.clockInTime,
  });

  @override
  State<EmployeeShiftCard> createState() => _EmployeeShiftCardState();
}

class _EmployeeShiftCardState extends State<EmployeeShiftCard>
    with SingleTickerProviderStateMixin {
  late bool _isClocked;
  DateTime? _clockInTime;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _isClocked = widget.isClocked;
    _clockInTime = widget.clockInTime;

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleClockIn() {
    setState(() {
      _isClocked = true;
      _clockInTime = DateTime.now();
    });
    widget.onClockIn?.call(_clockInTime!);
  }

  void _handleClockOut() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.w(20)),
          ),
          icon: Icon(
            Icons.logout_rounded,
            color: colorScheme.error,
            size: SizeConfig.w(48),
          ),
          title: Text(
            'End Shift?',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to end your shift?',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (_clockInTime != null) ...[
                SizedBox(height: SizeConfig.h(16)),
                Container(
                  padding: EdgeInsets.all(SizeConfig.w(12)),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: SizeConfig.w(16),
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: SizeConfig.w(8)),
                      Text(
                        'Started at ${_formatTime(_clockInTime!)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Continue',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);

                    final clockOutTime = DateTime.now();
                    widget.onClockOut?.call(clockOutTime);

                    setState(() {
                      _isClocked = false;
                      _clockInTime = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                    ),
                  ),
                  child: const Text('End Shift'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: _isClocked
                ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                : colorScheme.surfaceContainer.withValues(alpha: 0.5),

            borderRadius: BorderRadius.circular(SizeConfig.w(16)),
            border: Border.all(
              color: _isClocked
                  ? colorScheme.primary.withValues(alpha: 0.2)
                  : colorScheme.outlineVariant.withValues(alpha: 0.2),

              width: 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.w(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(SizeConfig.w(10)),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              SizeConfig.w(12),
                            ),
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            color: _isClocked
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            size: SizeConfig.w(24),
                          ),
                        ),
                        SizedBox(width: SizeConfig.w(12)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Shift Status",
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(2)),
                            Text(
                              _isClocked ? 'Active' : 'Not Started',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.w(14),
                        vertical: SizeConfig.h(8),
                      ),
                      decoration: BoxDecoration(
                        color: _isClocked
                            ? Colors.green.shade400
                            : colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(SizeConfig.w(20)),
                        boxShadow: _isClocked
                            ? [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isClocked)
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: SizeConfig.w(8),
                                height: SizeConfig.w(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          if (_isClocked) SizedBox(width: SizeConfig.w(6)),
                          Text(
                            _isClocked ? 'ON DUTY' : 'OFF DUTY',
                            style: textTheme.labelSmall?.copyWith(
                              color: _isClocked
                                  ? Colors.white
                                  : colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isClocked && _clockInTime != null) ...[
                  SizedBox(height: SizeConfig.h(16)),
                  Container(
                    padding: EdgeInsets.all(SizeConfig.w(16)),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(SizeConfig.w(8)),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(
                              SizeConfig.w(10),
                            ),
                          ),
                          child: Icon(
                            Icons.login_rounded,
                            color: colorScheme.onSecondaryContainer,
                            size: SizeConfig.w(20),
                          ),
                        ),
                        SizedBox(width: SizeConfig.w(12)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clock In Time',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(2)),
                            Text(
                              _formatTime(_clockInTime!),
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: SizeConfig.h(16)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isClocked ? _handleClockOut : _handleClockIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isClocked
                          ? colorScheme.errorContainer
                          : Colors.green.withValues(alpha: 0.6),
                      foregroundColor: colorScheme.onSurface,
                      padding: EdgeInsets.symmetric(vertical: SizeConfig.h(18)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                      ),
                      elevation: _isClocked ? 0 : 2,
                      shadowColor: _isClocked
                          ? Colors.transparent
                          : colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isClocked
                              ? Icons.logout_rounded
                              : Icons.login_rounded,
                          size: SizeConfig.w(22),
                        ),
                        SizedBox(width: SizeConfig.w(12)),
                        Text(
                          _isClocked ? 'End Shift' : 'Start Shift',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
