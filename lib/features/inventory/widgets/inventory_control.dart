import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/auth/widgets/form_elements.dart';

class InventoryControllCard extends StatelessWidget {
  const InventoryControllCard({super.key});

  void _showAddMedicineSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMedicineSheet(),
    );
  }

  void _showUpdateMedicineSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UpdateMedicineSheet(),
    );
  }

  void _showDeleteMedicineSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeleteMedicineSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.h(20)),
            Row(
              children: [
                Expanded(
                  child: HalfActionButton(
                    icon: Icons.settings,
                    label: "Add",
                    subtitle: 'Add Medicine',
                    onTap: () => _showAddMedicineSheet(context),
                    textTheme: Theme.of(context).textTheme,
                    backgroundColor: colorScheme.primaryContainer,
                    iconColor: colorScheme.onPrimaryContainer,
                    textColor: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(width: SizeConfig.w(16)),
                Expanded(
                  child: HalfActionButton(
                    icon: Icons.edit_outlined,
                    label: "Update",
                    subtitle: "Modify Stocks",
                    onTap: () => _showUpdateMedicineSheet(context),
                    backgroundColor: colorScheme.primaryContainer,
                    iconColor: colorScheme.onPrimaryContainer,
                    textColor: colorScheme.onPrimaryContainer,
                    textTheme: textTheme,
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.h(16)),
            FullActionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Remove Medicine',
              subtitle: 'Delete from inventory',
              backgroundColor: colorScheme.errorContainer,
              iconColor: colorScheme.onErrorContainer,
              textColor: colorScheme.onErrorContainer,
              textTheme: textTheme,
              onTap: () => _showDeleteMedicineSheet(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMedicineSheet extends StatefulWidget {
  @override
  State<_AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<_AddMedicineSheet> {
  bool _isLoading = false;
  String? _selectedType;
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _expiryController = TextEditingController();
  final List<TextEditingController> _substituteControllers = [];

  Future<void> _pickExpiryDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formatted =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() {
        _expiryController.text = formatted;
      });
    }
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _expiryController.dispose();
    for (var controller in _substituteControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSubstituteField() {
    setState(() {
      _substituteControllers.add(TextEditingController());
    });
  }

  void _removeSubstituteField(int index) {
    setState(() {
      _substituteControllers[index].dispose();
      _substituteControllers.removeAt(index);
    });
  }

  Future<void> _addMedicine(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;

          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConfig.w(20)),
            ),
            icon: Icon(
              Icons.vaccines_rounded,
              color: colorScheme.primary,
              size: SizeConfig.w(48),
            ),
            title: Text(
              'Confirmation!',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to add "${_medicineNameController.text.trim()}" to inventory.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final medName = _medicineNameController.text.trim();
                  final medQty = _quantityController.text.trim();
                  final medBs = _priceController.text.trim();
                  final medExpiry = _expiryController.text.trim();
                  final medType = _selectedType;

                  final inventory = FirebaseFirestore.instance
                      .collection("store")
                      .doc("default_store")
                      .collection("medicine");

                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await inventory.add({
                      'name': medName,
                      'quantity': medQty,
                      'batch_size': medBs,
                      'expiry': medExpiry,
                      'type': medType,
                      'substitute': _substituteControllers
                          .map((controller) => controller.text.trim())
                          .where((value) => value.isNotEmpty)
                          .toList(),
                    });

                    AppSnackbar.show(context, "$medName Added successfully!");
                  } catch (e) {
                    AppSnackbar.show(context, "Error: $e", isError: true);
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  context.pop();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.w(24)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: SizeConfig.w(16),
          right: SizeConfig.w(16),
          top: SizeConfig.h(24),
        ),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Medicine',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: colorScheme.onSurface,
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.h(16)),
                DropDownInput<String>(
                  label: "Medicine Type",
                  options: const [
                    "Tablet",
                    "Syrups",
                    "Injections",
                    "Ointment",
                    "Drops",
                    "Capsules",
                  ],
                  value: _selectedType,
                  onChanged: (val) => setState(() => _selectedType = val),
                  prefixIcon: Icons.category_outlined,
                  tileBuilder: (context, value) => ListTile(title: Text(value)),
                ),
                SizedBox(height: SizeConfig.h(16)),
                FormTextInput(
                  controller: _medicineNameController,
                  validator: FormValidators.name,
                  keyboardType: TextInputType.name,
                  label: "Medicine Name",
                  prefixIcon: Icons.medication,
                ),
                SizedBox(height: SizeConfig.h(16)),
                FormTextInput(
                  controller: _quantityController,
                  validator: (value) =>
                      FormValidators.number(int.tryParse(value ?? "")),
                  keyboardType: TextInputType.number,
                  label: "Quantity",
                  prefixIcon: Icons.numbers_outlined,
                ),
                SizedBox(height: SizeConfig.h(16)),
                FormTextInput(
                  controller: _priceController,
                  validator: (value) =>
                      FormValidators.number(int.tryParse(value ?? "")),
                  keyboardType: TextInputType.number,
                  label: "Price",
                  prefixIcon: Icons.currency_rupee_rounded,
                ),
                SizedBox(height: SizeConfig.h(16)),
                GestureDetector(
                  onTap: () => _pickExpiryDate(context),
                  child: AbsorbPointer(
                    child: FormTextInput(
                      controller: _expiryController,
                      validator: (value) {
                        if ((value ?? '').isEmpty) return 'Expiry required';
                        return null;
                      },
                      label: "Expiry Date",
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.h(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Substitutes (Optional)',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _addSubstituteField,
                      icon: const Icon(Icons.add_circle_outline),
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.h(8)),
                ..._substituteControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: SizeConfig.h(16)),
                    child: Row(
                      children: [
                        Expanded(
                          child: FormTextInput(
                            controller: controller,
                            validator: FormValidators.name,
                            keyboardType: TextInputType.name,
                            label: "Substitute ${index + 1}",
                            prefixIcon: Icons.medical_services_outlined,
                          ),
                        ),
                        SizedBox(width: SizeConfig.w(8)),
                        IconButton(
                          onPressed: () => _removeSubstituteField(index),
                          icon: const Icon(Icons.remove_circle_outline),
                          color: colorScheme.error,
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: SizeConfig.h(24)),
                FillButton(
                  onPress: () => _addMedicine(context),
                  text: "Add Medicine",
                  isLoading: _isLoading,
                ),
                SizedBox(height: SizeConfig.h(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdateMedicineSheet extends StatefulWidget {
  @override
  State<_UpdateMedicineSheet> createState() => _UpdateMedicineSheetState();
}

class _UpdateMedicineSheetState extends State<_UpdateMedicineSheet> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.text = '0';
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      int currentValue = int.tryParse(_quantityController.text) ?? 0;
      _quantityController.text = (currentValue + 1).toString();
    });
  }

  void _decrementQuantity() {
    setState(() {
      int currentValue = int.tryParse(_quantityController.text) ?? 0;
      _quantityController.text = (currentValue - 1).toString();
    });
  }

  Future<void> _updateMedicine(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;

          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConfig.w(20)),
            ),
            icon: Icon(
              Icons.vaccines_rounded,
              color: colorScheme.primary,
              size: SizeConfig.w(48),
            ),
            title: Text(
              'Confirmation!',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to update the quantity of "${_medicineNameController.text.trim()}".',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final medName = _medicineNameController.text.trim();
                  final delta =
                      int.tryParse(_quantityController.text.trim()) ?? 0;

                  if (medName.isEmpty) {
                    AppSnackbar.show(
                      context,
                      "Medicine Name is required",
                      isError: true,
                    );
                    return;
                  }

                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    final inventory = FirebaseFirestore.instance
                        .collection("store")
                        .doc("default_store")
                        .collection("medicine");

                    final query = await inventory
                        .where("name", isEqualTo: medName)
                        .limit(1)
                        .get();

                    if (query.docs.isEmpty) {
                      AppSnackbar.show(
                        context,
                        "$medName not found!",
                        isError: true,
                      );
                      return;
                    }

                    final docRef = query.docs.first.reference;

                    await docRef.update({
                      "quantity": FieldValue.increment(
                        delta,
                      ), // add or subtract based on +/- result
                    });

                    AppSnackbar.show(context, "Updated: $medName");
                  } catch (e) {
                    AppSnackbar.show(context, "Error: $e", isError: true);
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.w(24)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: SizeConfig.w(16),
          right: SizeConfig.w(16),
          top: SizeConfig.h(24),
        ),
        child: Form(
          child: SingleChildScrollView(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Update Quantity',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: colorScheme.onSurface,
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.h(16)),
                FormTextInput(
                  controller: _medicineNameController,
                  validator: FormValidators.name,
                  keyboardType: TextInputType.name,
                  label: "Medicine Name",
                  prefixIcon: Icons.medication,
                ),
                SizedBox(height: SizeConfig.h(24)),
                Text(
                  'Adjust Quantity',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: SizeConfig.h(16)),
                Container(
                  padding: EdgeInsets.all(SizeConfig.w(16)),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _decrementQuantity,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: colorScheme.primary,
                        iconSize: SizeConfig.w(32),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.w(16),
                          ),
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^-?\d*'),
                              ),
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  SizeConfig.w(8),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: SizeConfig.h(16),
                                horizontal: SizeConfig.w(16),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _incrementQuantity,
                        icon: const Icon(Icons.add_circle_outline),
                        color: colorScheme.primary,
                        iconSize: SizeConfig.w(32),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.h(16)),
                InfoCard(
                  title: "PLease Note:",
                  children: [
                    Text(
                      "This Quantity will be added/subtracted from the existing quantity in the inventory",
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.h(16)),
                Center(
                  child: Text(
                    _getQuantityChangeText(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: _getQuantityColor(colorScheme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.h(24)),
                FillButton(
                  onPress: () => _updateMedicine(context),
                  text: "Update Medicine",
                  isLoading: _isLoading,
                ),
                SizedBox(height: SizeConfig.h(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getQuantityChangeText() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity > 0) {
      return 'Adding $quantity units to inventory';
    } else if (quantity < 0) {
      return 'Removing ${quantity.abs()} units from inventory';
    } else {
      return 'No change in quantity';
    }
  }

  Color _getQuantityColor(ColorScheme colorScheme) {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity > 0) {
      return Colors.green;
    } else if (quantity < 0) {
      return colorScheme.error;
    } else {
      return colorScheme.onSurface.withOpacity(0.6);
    }
  }
}

class _DeleteMedicineSheet extends StatefulWidget {
  @override
  State<_DeleteMedicineSheet> createState() => _DeleteMedicineSheetState();
}

class _DeleteMedicineSheetState extends State<_DeleteMedicineSheet> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();

  @override
  void dispose() {
    _medicineNameController.dispose();
    super.dispose();
  }

  Future<void> _deleteMedicine(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;

          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConfig.w(20)),
            ),
            icon: Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.error,
              size: SizeConfig.w(48),
            ),
            title: Text(
              'Confirm Deletion',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${_medicineNameController.text}" from inventory? This action cannot be undone.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  final String medName = _medicineNameController.text.trim();
                  final inventory = FirebaseFirestore.instance
                      .collection("store")
                      .doc("default_store")
                      .collection("medicine");

                  final query = await inventory
                      .where("name", isEqualTo: medName)
                      .limit(1)
                      .get();

                  if (query.docs.isEmpty) {
                    AppSnackbar.show(
                      context,
                      'Medicine not found',
                      isError: true,
                    );
                    return;
                  }

                  await query.docs.first.reference.delete();

                  AppSnackbar.show(context, '$medName deleted successfully');
                  context.pop();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.w(24)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: SizeConfig.w(16),
          right: SizeConfig.w(16),
          top: SizeConfig.h(24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remove Medicine',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: colorScheme.onSurface,
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.h(16)),
              Container(
                padding: EdgeInsets.all(SizeConfig.w(16)),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.error,
                      size: SizeConfig.w(20),
                    ),
                    SizedBox(width: SizeConfig.w(16)),
                    Expanded(
                      child: Text(
                        'This will permanently remove the medicine batch',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.h(16)),
              FormTextInput(
                controller: _medicineNameController,
                validator: FormValidators.name,
                keyboardType: TextInputType.name,
                label: "Medicine Name",
                prefixIcon: Icons.medication,
              ),
              SizedBox(height: SizeConfig.h(24)),
              FillButton(
                onPress: () => _deleteMedicine(context),
                text: "Delete Medicine",
                isLoading: _isLoading,
              ),
              SizedBox(height: SizeConfig.h(24)),
            ],
          ),
        ),
      ),
    );
  }
}
