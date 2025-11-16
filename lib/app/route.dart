import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditech_v1/features/billing/screens/billing.dart';
import 'package:meditech_v1/features/home/screens/code_invite.dart';
import 'package:meditech_v1/features/home/screens/dashboard.dart';
import 'package:meditech_v1/features/home/screens/profile.dart';
import 'package:meditech_v1/features/inventory/screens/inventory.dart';
import 'package:meditech_v1/features/sales/screens/sales.dart';
import 'package:meditech_v1/features/screens.dart';

final GoRouter goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final loggedIn = Hive.box(
          'auth',
        ).get('isLoggedIn', defaultValue: false);
        return loggedIn ? '/dashboard' : '/intro';
      },
    ),

    // Introduction
    GoRoute(path: '/intro', builder: (context, state) => const WelcomeScreen()),

    //Sign Up
    GoRoute(
      path: '/credentials',
      builder: (context, state) => const RegisterCredentialScreen(),
    ),
    GoRoute(
      path: '/verify_email',
      builder: (context, state) => const EmailVerificationScreen(),
    ),
    GoRoute(
      path: '/select_role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/register_store',
      builder: (context, state) => const StoreRegistrationScreen(),
    ),
    GoRoute(
      path: '/register_user',
      builder: (context, state) => const UserRegistrationScreen(),
    ),

    // Sign in
    GoRoute(
      path: '/sign_in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Home
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/invite_code',
      builder: (context, state) => const InviteCodeScreen(),
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(path: '/sales', builder: (context, state) => const SalesScreen()),
    GoRoute(
      path: '/billing',
      builder: (context, state) => const BillingScreen(),
    ),
  ],
);
