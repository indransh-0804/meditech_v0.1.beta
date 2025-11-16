import 'package:flutter/material.dart';

class FormTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String label;
  final String? hint;
  final String? helper;

  const FormTextInput({
    super.key,
    required this.controller,
    required this.validator,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.hint,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear_outlined),
          onPressed: () => controller.clear(),
        ),
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class FormPasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String label;
  final String? hint;
  final String? helper;

  const FormPasswordInput({
    super.key,
    required this.controller,
    required this.validator,
    required this.label,
    this.keyboardType = TextInputType.visiblePassword,
    this.prefixIcon,
    this.hint,
    this.helper,
  });

  @override
  State<FormPasswordInput> createState() => _FormPasswordInputState();
}

class _FormPasswordInputState extends State<FormPasswordInput> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: obscure,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: IconButton(
          onPressed: () => setState(() => obscure = !obscure),
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
        labelText: widget.label,
        helperText: widget.helper,
        hintStyle: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class DropDownInput<T> extends StatefulWidget {
  final T? value;
  final List<T> options;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final ValueChanged<T?> onChanged;
  final Widget Function(BuildContext, T)? tileBuilder;
  final double borderRadius;

  const DropDownInput({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.hint,
    this.prefixIcon,
    this.tileBuilder,
    this.borderRadius = 12,
  });

  @override
  State<DropDownInput<T>> createState() => _DropDownInputState<T>();
}

class _DropDownInputState<T> extends State<DropDownInput<T>> {
  final _controller = TextEditingController();
  late T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
    _controller.text = _selectedValue?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MenuAnchor(
      builder: (context, controller, _) {
        return TextFormField(
          readOnly: true,
          controller: _controller,
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            labelText: widget.label,
            hintText: widget.hint,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.7,
            ),
            suffixIcon: Icon(
              controller.isOpen
                  ? Icons.arrow_drop_up_rounded
                  : Icons.arrow_drop_down_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
        );
      },
      menuChildren: [
        SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in widget.options)
                MenuItemButton(
                  onPressed: () {
                    setState(() {
                      _selectedValue = item;
                      _controller.text = item.toString();
                    });
                    widget.onChanged(item);
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                    backgroundColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
                  child:
                      widget.tileBuilder?.call(context, item) ??
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.store, color: colorScheme.primary),
                        title: Text(
                          item.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class TimePickerInput extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final IconData icon;
  final ValueChanged<TimeOfDay> onChanged;

  const TimePickerInput({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value != null ? value!.format(context) : "Select $label",
                style: textTheme.bodyLarge?.copyWith(
                  color: value != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant.withAlpha(150),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
