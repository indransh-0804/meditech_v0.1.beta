import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/auth/widgets/form_elements.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _forgotPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseAuthService.instance.sendPasswordResetEmail(
          context,
          _emailController.text,
        );
        AppSnackbar.show(context, "Password reset email send");
        context.go("/sign_in");
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
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(16),
                    vertical: SizeConfig.h(16),
                  ),
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(color: colorScheme.surface),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: SizeConfig.h(62)),
                        Text(
                          "Forgot Password?",
                          textAlign: TextAlign.center,
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(16)),
                        Text(
                          "Enter your registered email below to receive a password reset link.",
                          textAlign: TextAlign.center,
                          style: textTheme.titleSmall,
                        ),
                        SizedBox(height: SizeConfig.h(48)),
                        Form(
                          key: _formKey,
                          child: FormTextInput(
                            controller: _emailController,
                            validator: FormValidators.email,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            label: "Registered Email ID",
                            hint: "ramesh@gmail.com",
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(350)),
                        FillButton(
                          onPress: () => _forgotPassword(),
                          text: "Send Reset Link",
                          isLoading: _isLoading,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Back to Login",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
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
