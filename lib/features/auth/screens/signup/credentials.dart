import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/auth/widgets/form_elements.dart';
import 'package:meditech_v1/features/auth/widgets/pass_req.dart';

class RegisterCredentialScreen extends StatefulWidget {
  const RegisterCredentialScreen({super.key});

  @override
  State<RegisterCredentialScreen> createState() =>
      _RegisterCredentialScreenState();
}

class _RegisterCredentialScreenState extends State<RegisterCredentialScreen> {
  bool _isLoading = false;
  bool _hasUppercase(String s) => RegExp(r'[A-Z]').hasMatch(s);
  bool _hasLowercase(String s) => RegExp(r'[a-z]').hasMatch(s);
  bool _hasDigit(String s) => RegExp(r'\d').hasMatch(s);
  bool _hasSpecialChar(String s) =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(s);
  bool _hasMinLength(String s) => s.length >= 8;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cpasswordController.dispose();
    super.dispose();
  }

  void _registerCredentials() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseAuthService.instance.registerUserWithEmail(
          context,
          _emailController.text,
          _passwordController.text,
        );
        context.push("/verify_email");
      } catch (e) {
        AppSnackbar.show(
          context,
          "Internal Error: Please try again",
          isError: true,
        );
      } finally {
        setState(() => _isLoading = false);
      }
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
              onTap: () => FocusScope.of(context).unfocus(),
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
                              SizedBox(height: SizeConfig.h(16)),
                              Text(
                                "Lets get started",
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: SizeConfig.h(16)),
                              Text(
                                "Please choose an email and password as your credential.",
                                textAlign: TextAlign.center,
                                style: textTheme.titleSmall,
                              ),
                              SizedBox(height: SizeConfig.h(40)),
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FormTextInput(
                                      controller: _emailController,
                                      validator: FormValidators.email,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email_outlined,
                                      label: "Email ID",
                                      hint: "ramesh@gmail.com",
                                    ),
                                    SizedBox(height: SizeConfig.h(16)),
                                    FormPasswordInput(
                                      controller: _passwordController,
                                      validator: FormValidators.password,
                                      prefixIcon: Icons.lock_outline,
                                      label: "Password",
                                    ),
                                    SizedBox(height: SizeConfig.h(16)),
                                    FormPasswordInput(
                                      controller: _cpasswordController,
                                      validator: (value) =>
                                          FormValidators.confirmPassword(
                                            value,
                                            _cpasswordController.text,
                                          ),
                                      prefixIcon: Icons.lock_reset_outlined,
                                      label: "Confirm Password",
                                    ),
                                    SizedBox(height: SizeConfig.h(16)),
                                    AnimatedBuilder(
                                      animation: _passwordController,
                                      builder: (context, _) {
                                        final pwd = _passwordController.text;
                                        return InfoCard(
                                          title: "Password must contain:",
                                          children: [
                                            PasswordRequirement(
                                              text: "Minimum 8 characters",
                                              satisfied: _hasMinLength(pwd),
                                            ),
                                            PasswordRequirement(
                                              text: "At least 1 upper letter",
                                              satisfied: _hasUppercase(pwd),
                                            ),
                                            PasswordRequirement(
                                              text: "At least 1 lower letter",
                                              satisfied: _hasLowercase(pwd),
                                            ),
                                            PasswordRequirement(
                                              text:
                                                  "At least 1 special character",
                                              satisfied: _hasSpecialChar(pwd),
                                            ),
                                            PasswordRequirement(
                                              text: "At least 1 digit",
                                              satisfied: _hasDigit(pwd),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: SizeConfig.h(48)),
                              FillButton(
                                onPress: _registerCredentials,
                                text: "Verify Email",
                                isLoading: _isLoading,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: textTheme.bodyMedium,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      context.go("/sign_in");
                                    },
                                    child: Text(
                                      "Sign In",
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
