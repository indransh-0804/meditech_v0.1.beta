import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditech_v1/core/core.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.w(16),
            vertical: SizeConfig.h(16),
          ),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(SizeConfig.w(24)),
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(SizeConfig.w(20)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: SizeConfig.w(16),
                    offset: Offset(0, SizeConfig.h(8)),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Heading
                  Text(
                    "Welcome to",
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(12)),
                  Text(
                    "MediTech",
                    style: textTheme.displayMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  SizedBox(height: SizeConfig.h(40)),

                  // Illustration
                  SizedBox(
                    height: SizeConfig.h(150),
                    child: AspectRatio(
                      aspectRatio: 1.2,
                      child: Image.asset(
                        "assets/imgs/intro.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: SizeConfig.h(40)),

                  Text(
                    "Sign in if you have an account\nor sign up if you don't.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),

                  SizedBox(height: SizeConfig.h(28)),

                  Container(
                    width: SizeConfig.w(140),
                    height: 2,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(SizeConfig.w(1)),
                    ),
                  ),

                  SizedBox(height: SizeConfig.h(28)),

                  // Buttons (FIXED)
                  Row(
                    children: [
                      Expanded(
                        child: FillButton(
                          onPress: () {
                            Hive.box("roleBox").clear();
                            context.go("/sign_in");
                          },
                          text: "Sign In",
                        ),
                      ),
                      SizedBox(width: SizeConfig.w(16)),
                      Expanded(
                        child: FillButton(
                          onPress: () {
                            Hive.box("roleBox").clear();
                            context.go("/credentials");
                          },
                          text: "Sign Up",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
