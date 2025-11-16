import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/auth/widgets/form_elements.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  late final String? role;

  @override
  void initState() {
    super.initState();
    role = Hive.box("roleBox").get("role");
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget body;
    switch (role) {
      case "owner":
        body = const OwnerRegistration();
        break;
      case "employee":
        body = const EmployeeRegistration();
        break;
      default:
        body = const Center(child: Text("Roles not recognized"));
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(16),
          vertical: SizeConfig.h(16),
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(16),
                    vertical: SizeConfig.h(16),
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: body,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OwnerRegistration extends StatefulWidget {
  const OwnerRegistration({super.key});

  @override
  State<OwnerRegistration> createState() => _OwnerRegistrationState();
}

class _OwnerRegistrationState extends State<OwnerRegistration> {
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: SizeConfig.h(24)),
        Text(
          "Owner Registration",
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: SizeConfig.h(16)),
        Text(
          "Complete your registration as owner of the store below",
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: SizeConfig.h(32)),
        Form(
          key: _formKey,
          child: Column(
            children: [
              FormTextInput(
                controller: _nameController,
                validator: FormValidators.name,
                keyboardType: TextInputType.name,
                prefixIcon: Icons.person_outlined,
                label: "Owner's Full Name",
                hint: "Ramesh Yadav",
              ),
              SizedBox(height: SizeConfig.h(16)),
              FormTextInput(
                controller: _contactController,
                validator: FormValidators.contact,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.phone_outlined,
                label: "Owner's Contact",
                hint: "987654321",
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.h(16)),
        FillButton(
          onPress: () {
            if (_formKey.currentState!.validate()) {
              registerOwner(context);
              Hive.box('auth').put('isLoggedIn', true);
            }
          },
          text: "Register",
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> registerOwner(BuildContext context) async {
    setState(() => _isLoading = true);

    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      AppSnackbar.show(context, "Invalid User", isError: true);
      setState(() => _isLoading = false);
      return;
    }

    final userRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);

    final storeRef = FirebaseFirestore.instance
        .collection("store")
        .doc("default_store")
        .collection("owners");

    final email = user.email;

    try {
      await userRef.set({
        'name': _nameController.text.trim(),
        'contact': _contactController.text.trim(),
        'email': email,
        'registered_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await storeRef.doc(user.uid).set({
        'name': _nameController.text.trim(),
        'joined_at': FieldValue.serverTimestamp(),
      });

      AppSnackbar.show(context, "Registered Successfully!");
      context.go("/dashboard");
    } catch (e) {
      AppSnackbar.show(context, "Failed to Register: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class EmployeeRegistration extends StatefulWidget {
  const EmployeeRegistration({super.key});

  @override
  State<EmployeeRegistration> createState() => _EmployeeRegistrationState();
}

class _EmployeeRegistrationState extends State<EmployeeRegistration> {
  bool _isLoading = false;
  String? selectGender;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: SizeConfig.h(24)),
        Text(
          "Employee Registration",
          textAlign: TextAlign.center,
          style: textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: SizeConfig.h(16)),
        Text(
          "Complete your registration as employee of the store below",
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: SizeConfig.h(32)),
        Form(
          key: _formKey,
          child: Column(
            children: [
              FormTextInput(
                controller: _nameController,
                validator: FormValidators.name,
                keyboardType: TextInputType.name,
                prefixIcon: Icons.person_outlined,
                label: "Full Name",
                hint: "Ramesh Yadav",
              ),
              SizedBox(height: SizeConfig.h(16)),
              FormTextInput(
                controller: _contactController,
                validator: FormValidators.contact,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.phone_outlined,
                label: "Contact",
                hint: "987654321",
              ),
              SizedBox(height: SizeConfig.h(16)),
              FormTextInput(
                controller: _ageController,
                validator: (value) =>
                    FormValidators.age(int.tryParse(value ?? "")),
                keyboardType: TextInputType.number,
                prefixIcon: Icons.calendar_today_outlined,
                label: "Age",
                hint: "",
              ),
              DropDownInput<String>(
                label: 'Gender',
                options: const ['Male', 'Female'],
                value: selectGender,
                onChanged: (val) => setState(() => selectGender = val),
                prefixIcon: Icons.wc_rounded,
                tileBuilder: (context, value) => ListTile(
                  leading: Icon(
                    value == 'Male' ? Icons.male_rounded : Icons.female_rounded,
                  ),
                  title: Text(value),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.h(16)),
        FillButton(
          onPress: () {
            if (_formKey.currentState!.validate()) {
              registerEmployee(context);
              Hive.box('auth').put('isLoggedIn', true);
              context.go("/dashboard");
            }
          },
          text: "Register",
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> registerEmployee(BuildContext context) async {
    setState(() => _isLoading = true);

    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      AppSnackbar.show(context, "Invalid User", isError: true);
      setState(() => _isLoading = false);
      return;
    }

    final userRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);

    final storeRef = FirebaseFirestore.instance
        .collection("store")
        .doc("default_store")
        .collection("employees");

    try {
      await userRef.set({
        'name': _nameController.text.trim(),
        'contact': _contactController.text.trim(),
        'registered_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await storeRef.add({
        'name': _nameController.text.trim(),
        'joined_at': FieldValue.serverTimestamp(),
      });

      AppSnackbar.show(context, "Registered Successfully!");
    } catch (e) {
      AppSnackbar.show(context, "Failed to Register: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
