import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/auth/widgets/form_elements.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool obscure = true;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Sign in first
      await FirebaseAuthService.instance.signInWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. Get signed-in user ID
      final uid = FirebaseAuthService.instance.currentUser!.uid;

      // 3. Fetch role from Firestore
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!snap.exists) {
        AppSnackbar.show(context, "User data not found", isError: true);
        return;
      }

      final role = snap.data()?['role'];

      if (role == null) {
        AppSnackbar.show(context, "Role not found", isError: true);
        return;
      }

      // 4. Store role in Hive
      Hive.box("roleBox").put("role", role);

      // 5. Mark login status
      Hive.box('auth').put('isLoggedIn', true);

      // 6. Navigate to dashboard
      context.go("/dashboard");
    } catch (e) {
      AppSnackbar.show(context, "Login failed: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Focus(
        child: Builder(
          builder: (context) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.w(16),
                  vertical: SizeConfig.h(16),
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh.withValues(
                    alpha: 0.6,
                  ),
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
                            borderRadius: BorderRadius.circular(
                              SizeConfig.w(16),
                            ),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.25,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withValues(
                                  alpha: 0.25,
                                ),
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
                                "Welcome Back!",
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: SizeConfig.h(16)),
                              Text(
                                "Please enter your registered email and password to proceed.",
                                textAlign: TextAlign.center,
                                style: textTheme.titleSmall,
                              ),
                              SizedBox(height: SizeConfig.h(56)),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Email Field
                                    FormTextInput(
                                      controller: _emailController,
                                      validator: FormValidators.email,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email_outlined,
                                      label: "Email ID",
                                      hint: "ramesh@gmail.com",
                                    ),
                                    SizedBox(height: SizeConfig.h(16)),
                                    // Password Field
                                    FormPasswordInput(
                                      controller: _passwordController,
                                      validator: FormValidators.password,
                                      prefixIcon: Icons.password_outlined,
                                      label: "Password",
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: SizeConfig.h(16)),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    context.push("/forgot_password");
                                  },
                                  child: Text(
                                    "forgot your password?",
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.tertiary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: SizeConfig.h(40)),
                              FillButton(
                                onPress: () => _signin(),
                                text: "Sign In",
                                isLoading: _isLoading,
                              ),
                              SizedBox(height: SizeConfig.h(24)),
                            ],
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(48)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: textTheme.bodyMedium,
                            ),
                            InkWell(
                              onTap: () {
                                context.go("/credentials");
                              },
                              child: Text(
                                "Sign Up",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.tertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
