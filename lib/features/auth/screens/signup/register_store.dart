import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/auth/widgets/form_elements.dart';

class StoreRegistrationScreen extends StatefulWidget {
  const StoreRegistrationScreen({super.key});

  @override
  State<StoreRegistrationScreen> createState() =>
      _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> {
  late final String? role;

  @override
  void initState() {
    super.initState();
    role = Hive.box("roleBox").get("role");
  }

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case "owner":
        return const OwnerStoreRegistration();
      case "employee":
        return const EmployeeStoreRegistration();
      default:
        return const Scaffold(
          body: Center(child: Text("Roles not recognized")),
        );
    }
  }
}

class OwnerStoreRegistration extends StatefulWidget {
  const OwnerStoreRegistration({super.key});

  @override
  State<OwnerStoreRegistration> createState() => _OwnerStoreRegistrationState();
}

class _OwnerStoreRegistrationState extends State<OwnerStoreRegistration> {
  bool _loading = false;

  final _newStoreFormKey = GlobalKey<FormState>();
  final _existingStoreFormKey = GlobalKey<FormState>();

  String? _selectedOption;
  String? _selectedStoreType;
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final pinCtrl = TextEditingController();
  final inviteCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    pinCtrl.dispose();
    inviteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(SizeConfig.w(16)),
            child: Column(
              children: [
                _header(tt, cs),
                SizedBox(height: 24),
                if (_selectedOption != null)
                  _selectedOption == "Register a New Store"
                      ? _newStoreForm(context, tt, cs)
                      : _existingStoreForm(context, tt, cs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(TextTheme tt, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.w(16)),
      decoration: _box(cs),
      child: Column(
        children: [
          Text(
            "Store Registration",
            style: tt.headlineMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          DropDownInput(
            label: "Register/Select Store",
            value: _selectedOption,
            options: const ["Already Registered", "Register a New Store"],
            onChanged: (v) => setState(() => _selectedOption = v),
            prefixIcon: Icons.store_outlined,
            tileBuilder: (c, v) => ListTile(title: Text(v)),
          ),
        ],
      ),
    );
  }

  Widget _newStoreForm(BuildContext context, TextTheme tt, ColorScheme cs) {
    return Form(
      key: _newStoreFormKey,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.w(16)),
        decoration: _box(cs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Register a New Store",
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            SizedBox(height: 24),

            // Store name
            FormTextInput(
              controller: nameCtrl,
              validator: FormValidators.name,
              label: "Store Name",
              prefixIcon: Icons.storefront_outlined,
            ),
            SizedBox(height: 16),

            // Store type
            DropDownInput<String>(
              label: "Store Type",
              value: _selectedStoreType,
              options: const [
                'Private Medical Store',
                'Govt. Medical Store',
                'Specialized Medical Store',
                'Surgical Items Store',
                'Community Owned Store',
              ],
              onChanged: (v) => setState(() => _selectedStoreType = v),
              prefixIcon: Icons.category_outlined,
              tileBuilder: (c, v) => ListTile(title: Text(v)),
            ),
            SizedBox(height: 16),

            // Email
            FormTextInput(
              controller: emailCtrl,
              validator: FormValidators.email,
              label: "Email",
              prefixIcon: Icons.email_outlined,
            ),
            SizedBox(height: 24),

            // Address
            FormTextInput(
              controller: addressCtrl,
              validator: FormValidators.address,
              label: "Address",
              prefixIcon: Icons.location_on_outlined,
            ),
            SizedBox(height: 16),

            // City
            FormTextInput(
              controller: cityCtrl,
              validator: FormValidators.name,
              label: "City",
              prefixIcon: Icons.location_city_outlined,
            ),
            SizedBox(height: 16),

            // Pin
            FormTextInput(
              controller: pinCtrl,
              validator: FormValidators.areaCode,
              keyboardType: TextInputType.number,
              label: "Pincode",
              prefixIcon: Icons.pin_drop_outlined,
            ),
            SizedBox(height: 24),

            // Time pickers
            Row(
              children: [
                Expanded(
                  child: TimePickerInput(
                    label: "Opening Time",
                    value: _openTime,
                    icon: Icons.schedule_outlined,
                    onChanged: (v) => setState(() => _openTime = v),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TimePickerInput(
                    label: "Closing Time",
                    value: _closeTime,
                    icon: Icons.access_time_outlined,
                    onChanged: (v) => setState(() => _closeTime = v),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),

            Center(
              child: FillButton(
                text: "Register Store",
                isLoading: _loading,
                onPress: () async {
                  if (!_newStoreFormKey.currentState!.validate()) return;
                  if (_openTime == null || _closeTime == null) {
                    AppSnackbar.show(context, "Select store timings");
                    return;
                  }

                  await _registerNewStore(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _existingStoreForm(
    BuildContext context,
    TextTheme tt,
    ColorScheme cs,
  ) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.w(16)),
      decoration: _box(cs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Already Registered",
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          SizedBox(height: 16),

          Form(
            key: _existingStoreFormKey,
            child: FormTextInput(
              controller: inviteCtrl,
              validator: FormValidators.inviteCode,
              label: "Invite Code",
              prefixIcon: Icons.code_outlined,
              hint: "A1B2C3D4",
            ),
          ),
          SizedBox(height: 24),

          Center(
            child: FillButton(
              text: "Join Store",
              isLoading: _loading,
              onPress: () async {
                if (!_existingStoreFormKey.currentState!.validate()) return;
                await _joinStore(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _box(ColorScheme cs) {
    return BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      boxShadow: [
        BoxShadow(
          color: cs.shadow.withOpacity(0.25),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  Future<void> _registerNewStore(BuildContext context) async {
    setState(() => _loading = true);

    try {
      final storeRef = FirebaseFirestore.instance
          .collection("store")
          .doc("default_store");

      await storeRef.update({
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'store_type': _selectedStoreType,
        'location': {
          'address': addressCtrl.text.trim(),
          'city': cityCtrl.text.trim(),
          'area_code': pinCtrl.text.trim(),
        },
        'time': {
          'open': _openTime!.format(context),
          'close': _closeTime!.format(context),
        },
        'updated_at': FieldValue.serverTimestamp(),
      });

      context.go("/register_user");

      AppSnackbar.show(context, "Store registered!");
    } catch (e) {
      AppSnackbar.show(context, "Error: $e", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _joinStore(BuildContext context) async {
    setState(() => _loading = true);

    try {
      final storeRef = FirebaseFirestore.instance
          .collection("store")
          .doc("default_store");

      final snap = await storeRef.get();

      if (!snap.exists) {
        AppSnackbar.show(context, "Store not found", isError: true);
        return;
      }

      final invite = snap['invite_code'].toString().toLowerCase().trim();
      final entered = inviteCtrl.text.toLowerCase().trim();

      if (invite != entered) {
        AppSnackbar.show(context, "Invalid invite code", isError: true);
        return;
      }

      context.go("/register_user");

      AppSnackbar.show(context, "Store linked!");
    } catch (e) {
      AppSnackbar.show(context, "Failed: $e", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }
}

class EmployeeStoreRegistration extends StatefulWidget {
  const EmployeeStoreRegistration({super.key});

  @override
  State<EmployeeStoreRegistration> createState() =>
      _EmployeeStoreRegistrationState();
}

class _EmployeeStoreRegistrationState extends State<EmployeeStoreRegistration> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final inviteCtrl = TextEditingController();

  @override
  void dispose() {
    inviteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(SizeConfig.w(16)),
            child: Container(
              padding: EdgeInsets.all(SizeConfig.w(16)),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.25),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 12),
                  Text(
                    "Store Invite Code",
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.secondary,
                    ),
                  ),
                  SizedBox(height: 16),

                  Form(
                    key: _formKey,
                    child: FormTextInput(
                      controller: inviteCtrl,
                      validator: FormValidators.inviteCode,
                      label: "Invite Code",
                      prefixIcon: Icons.code_outlined,
                      hint: "A1B2C3D4",
                    ),
                  ),
                  SizedBox(height: 24),

                  FillButton(
                    text: "Join Store",
                    isLoading: _loading,
                    onPress: () async {
                      if (!_formKey.currentState!.validate()) return;
                      await _joinStore(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _joinStore(BuildContext context) async {
    setState(() => _loading = true);

    try {
      final storeRef = FirebaseFirestore.instance
          .collection("store")
          .doc("default_store");

      final snap = await storeRef.get();

      if (!snap.exists) {
        AppSnackbar.show(context, "Store not found", isError: true);
        return;
      }

      final invite = snap['invite_code'].toString().toLowerCase().trim();
      final entered = inviteCtrl.text.toLowerCase().trim();

      if (invite != entered) {
        AppSnackbar.show(context, "Invalid invite code", isError: true);
        return;
      }

      context.go("/register_user");

      AppSnackbar.show(context, "Store linked!");
    } catch (e) {
      AppSnackbar.show(context, "Error: $e", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }
}
