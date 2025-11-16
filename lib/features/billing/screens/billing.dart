import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/auth/widgets/form_elements.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _customerPhoneController = TextEditingController();
  final _customerAgeController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;
  final List<Medicine> _medicines = [];

  @override
  void dispose() {
    _customerPhoneController.dispose();
    _customerAgeController.dispose();
    super.dispose();
  }

  Future<void> registerCustomer(BuildContext context) async {
    if (_selectedGender == null) {
      AppSnackbar.show(context, "Please select gender", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final String customerContact = _customerPhoneController.text.trim();
    final String customerAge = _customerAgeController.text.trim();
    final String customerGender = _selectedGender!.toLowerCase();

    final customers = FirebaseFirestore.instance
        .collection("store")
        .doc("default_store")
        .collection("customers");

    try {
      await customers.add({
        'contact': customerContact,
        'age': customerAge,
        'gender': customerGender,
        'shopped_at': FieldValue.serverTimestamp(),
      });

      AppSnackbar.show(context, "Registered Successfully!");
    } catch (e) {
      AppSnackbar.show(context, "Failed to Register: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppBaar(header: "Billing", isBackable: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(8),
          vertical: SizeConfig.h(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              color: colorScheme.primaryContainer.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.w(16)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.w(16),
                  vertical: SizeConfig.h(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: colorScheme.onPrimaryContainer,
                          size: SizeConfig.w(24),
                        ),
                        SizedBox(width: SizeConfig.w(8)),
                        Text(
                          'Customer Details',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.h(16)),
                    FormTextInput(
                      controller: _customerPhoneController,
                      validator: FormValidators.contact,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      label: "Customer's Contact",
                      hint: "987654321",
                    ),
                    SizedBox(height: SizeConfig.h(16)),
                    FormTextInput(
                      controller: _customerAgeController,
                      label: 'Age',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.calendar_today_outlined,
                      validator: (value) =>
                          FormValidators.age(int.tryParse(value ?? "")),
                    ),
                    SizedBox(height: SizeConfig.h(16)),
                    DropDownInput<String>(
                      label: "Gender",
                      options: const ["Male", "Female"],
                      value: _selectedGender,
                      onChanged: (val) => setState(() => _selectedGender = val),
                      prefixIcon: Icons.wc_rounded,
                      tileBuilder: (context, value) => ListTile(
                        leading: Icon(
                          value == 'Male'
                              ? Icons.male_outlined
                              : Icons.female_outlined,
                        ),
                        title: Text(value),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: SizeConfig.h(16)),

            Card(
              elevation: 4,
              color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.w(16)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.w(16),
                  vertical: SizeConfig.h(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              color: colorScheme.onSecondaryContainer,
                              size: SizeConfig.w(24),
                            ),
                            SizedBox(width: SizeConfig.w(16)),
                            Text(
                              'Medicines',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(SizeConfig.w(20)),
                                ),
                              ),
                              builder: (context) => ManualMedicineEntry(
                                onAdd: (medicine) {
                                  setState(() => _medicines.add(medicine));
                                },
                              ),
                            );
                          },
                          icon: Icon(Icons.add, size: SizeConfig.w(18)),
                          label: const Text('Add'),
                        ),
                      ],
                    ),

                    SizedBox(height: SizeConfig.h(16)),

                    if (_medicines.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.h(32),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_shopping_cart_outlined,
                                size: SizeConfig.w(48),
                                color: colorScheme.onSecondaryContainer
                                    .withValues(alpha: 0.5),
                              ),
                              SizedBox(height: SizeConfig.h(8)),
                              Text(
                                'No medicines added yet',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSecondaryContainer
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _medicines.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: SizeConfig.h(8)),
                        itemBuilder: (context, index) {
                          final medicine = _medicines[index];
                          return MedicineListItem(
                            medicine: medicine,
                            onDelete: () {
                              setState(() => _medicines.removeAt(index));
                            },
                          );
                        },
                      ),

                    SizedBox(height: SizeConfig.h(24)),
                    FillButton(
                      onPress: () async {
                        if (_medicines.isEmpty) {
                          AppSnackbar.show(
                            context,
                            "Add medicines before generating bill",
                            isError: true,
                          );
                          return;
                        }

                        await registerCustomer(context);
                        context.pop();
                      },
                      text: "Generate Bill",
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                MEDICINE ITEM                               */
/* -------------------------------------------------------------------------- */

class MedicineListItem extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onDelete;

  const MedicineListItem({
    super.key,
    required this.medicine,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(16),
        vertical: SizeConfig.h(16),
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(SizeConfig.w(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.w(8)),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(SizeConfig.w(8)),
            ),
            child: Icon(
              Icons.medication_outlined,
              color: colorScheme.onPrimaryContainer,
              size: SizeConfig.w(20),
            ),
          ),
          SizedBox(width: SizeConfig.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: SizeConfig.h(4)),
                Text(
                  'Quantity: ${medicine.quantity}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
          ),
        ],
      ),
    );
  }
}

class ManualMedicineEntry extends StatefulWidget {
  final Function(Medicine) onAdd;
  const ManualMedicineEntry({super.key, required this.onAdd});

  @override
  State<ManualMedicineEntry> createState() => _ManualMedicineEntryState();
}

class _ManualMedicineEntryState extends State<ManualMedicineEntry> {
  final _medicineNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _medicineNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> addBillingItemToFirestore(Medicine medicine) async {
    setState(() => _saving = true);

    final storeRef = FirebaseFirestore.instance
        .collection("store")
        .doc("default_store");

    try {
      final query = await storeRef
          .collection('medicine')
          .where('name', isEqualTo: medicine.name)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        AppSnackbar.show(context, "Medicine not found", isError: true);
        return;
      }

      final docRef = query.docs.first.reference;
      final unitPrice = query.docs.first.data()['unitPrice'] * 1.0;

      final amount = unitPrice * medicine.quantity;

      await docRef.update({
        "quantity": FieldValue.increment(-medicine.quantity),
        "lastUpdatedAt": FieldValue.serverTimestamp(),
        "lastUpdatedBy": "billing",
      });

      final now = DateTime.now();
      final docId = "${now.year}-${now.month}-${now.day}";

      await storeRef.collection('sales').doc(docId).set({
        'date': Timestamp.fromDate(now),
        'items': FieldValue.arrayUnion([
          {
            'name': medicine.name,
            'quantity': medicine.quantity,
            'amount': amount,
          },
        ]),
      }, SetOptions(merge: true));
    } catch (e) {
      AppSnackbar.show(context, "Billing failed: $e", isError: true);
    } finally {
      setState(() => _saving = false);
    }
  }

  void _addMedicine() async {
    if (_formKey.currentState!.validate()) {
      final medicine = Medicine(
        name: _medicineNameController.text.trim(),
        quantity: int.parse(_quantityController.text.trim()),
      );

      await addBillingItemToFirestore(medicine);
      widget.onAdd(medicine);

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
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
                  'Add Medicine',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
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
            SizedBox(height: SizeConfig.h(16)),
            FormTextInput(
              controller: _quantityController,
              validator: (value) =>
                  FormValidators.number(int.tryParse(value ?? "")),
              keyboardType: TextInputType.number,
              label: "Quantity",
              prefixIcon: Icons.numbers_outlined,
            ),
            SizedBox(height: SizeConfig.h(24)),
            FillButton(
              onPress: () => _saving
                  ? null
                  : () {
                      _addMedicine();
                    },
              text: _saving ? "Saving..." : "Add Medicine",
              isLoading: _saving,
            ),
            SizedBox(height: SizeConfig.h(24)),
          ],
        ),
      ),
    );
  }
}

class Medicine {
  final String name;
  final int quantity;

  Medicine({required this.name, required this.quantity});
}
