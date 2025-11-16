import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditech_v1/features/auth/widgets/role_card.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = false;
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: SizeConfig.h(24)),
                      Text(
                        "Continue As ...",
                        textAlign: TextAlign.center,
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(16)),
                      Text(
                        "Select the role that fits your job description",
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(72)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RoleCard(
                                  role: "Employee",
                                  icon: Icons.badge_outlined,
                                  selected: selectedRole == "employee",
                                  onTap: () {
                                    setState(() => selectedRole = "employee");
                                  },
                                ),
                              ),
                              SizedBox(width: SizeConfig.w(16)),
                              Expanded(
                                child: RoleCard(
                                  role: "Owner",
                                  icon: Icons.store_outlined,
                                  selected: selectedRole == "owner",
                                  onTap: () {
                                    setState(() => selectedRole = "owner");
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig.h(72)),
                      FillButton(
                        onPress: () => selectRole(context),
                        text: "Register Yourself",
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectRole(BuildContext context) async {
    if (selectedRole == null) {
      AppSnackbar.show(
        context,
        "Please select a role before continuing.",
        isError: true,
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuthService.instance.currentUser;
      if (user == null) {
        AppSnackbar.show(
          context,
          "No authenticated user found.",
          isError: true,
        );
        return;
      }
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      await userRef.set({
        "uid": user.uid,
        "role": selectedRole!.toLowerCase(),
        "role_selected_at": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await Hive.box('roleBox').put('role', selectedRole!.toLowerCase());
      AppSnackbar.show(context, "Role set to $selectedRole");
      context.go("/register_store");
    } catch (e) {
      AppSnackbar.show(context, "Something went wrong: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
