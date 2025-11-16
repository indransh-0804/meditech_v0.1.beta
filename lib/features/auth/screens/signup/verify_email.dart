import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditech_v1/core/core.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService.instance;
  Timer? _pollTimer;
  Timer? _resendCooldownTimer;
  int _resendCooldownSeconds = 0;
  bool _isSending = false;
  static const int _pollIntervalSeconds = 5;
  static const int _resendCooldownInitial = 30;

  User? get _user => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      });
      return;
    }

    if (_user!.emailVerified) {
      _onVerified();
    } else {
      _startPolling();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: _pollIntervalSeconds),
      (_) => _checkEmailVerified(),
    );
  }

  Future<void> _checkEmailVerified() async {
    try {
      await _user?.reload();
      final reloaded = _auth.currentUser;
      if (reloaded != null && reloaded.emailVerified) {
        _pollTimer?.cancel();
        if (!mounted) return;
        AppSnackbar.show(context, "Email verified");
        _onVerified();
      }
    } catch (e) {}
  }

  void _onVerified() {
    context.go("/select_role");
  }

  Future<void> _sendVerificationEmail() async {
    final user = _user;
    if (user == null) return;

    if (_resendCooldownSeconds > 0) {
      AppSnackbar.show(
        context,
        'Please wait $_resendCooldownSeconds s before resending.',
        isError: true,
      );
      return;
    }

    try {
      setState(() => _isSending = true);
      await user.sendEmailVerification();
      _startResendCooldown();

      if (!mounted) return;
      AppSnackbar.show(
        context,
        'Verification email sent. Check inbox or spam.',
      );
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'too-many-requests' => 'Too many requests. Try again later.',
        _ => 'Failed to send verification email. Try again.',
      };
      if (mounted) {
        AppSnackbar.show(context, message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context,
          'Unexpected error while sending verification.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startResendCooldown() {
    _resendCooldownTimer?.cancel();
    _resendCooldownSeconds = _resendCooldownInitial;
    setState(() {});

    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendCooldownSeconds -= 1);
      if (_resendCooldownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _manualCheckNow() async {
    await _checkEmailVerified();
    if (mounted) {
      AppSnackbar.show(context, 'Checked verification status.');
    }
  }

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
        decoration: BoxDecoration(color: colorScheme.surface),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: SizeConfig.h(62)),
                    Text(
                      "Verify Your Email",
                      textAlign: TextAlign.center,
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(32)),
                    Text(
                      "We sent a verification link to:",
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium,
                    ),
                    Text(
                      "Indransh Sharma",
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.h(96)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
                  child: Text(
                    "Open your email and click the verification link.\n"
                    "If it lands in spam, mark it NOT SPAM and/or add the sender to your contacts.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ),
                SizedBox(height: SizeConfig.h(152)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FillButton(
                      onPress: () => _manualCheckNow(),
                      text: "Already Verified",
                    ),
                    SizedBox(height: SizeConfig.h(16)),
                    Row(
                      children: [
                        Expanded(child: Divider(color: colorScheme.onSurface)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.w(16),
                          ),
                          child: Text(
                            "didn't get the email ?",
                            style: textTheme.titleSmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: colorScheme.onSurface)),
                      ],
                    ),
                    SizedBox(height: SizeConfig.h(16)),
                    OutlinedButton(
                      onPressed: (_isSending || _resendCooldownSeconds > 0)
                          ? null
                          : _sendVerificationEmail,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _resendCooldownSeconds > 0
                                  ? 'Resend Email in $_resendCooldownSeconds s'
                                  : 'Resend Email',
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    SizedBox(height: SizeConfig.h(16)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
