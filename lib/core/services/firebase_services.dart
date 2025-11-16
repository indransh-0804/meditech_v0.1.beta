import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditech_v1/core/core.dart';

class FirebaseAuthService {
  FirebaseAuthService._privateConstructor();
  static final FirebaseAuthService instance =
      FirebaseAuthService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Helpers -------------------------------------------------------------

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Map common FirebaseAuthException codes to readable messages
  String _friendlyFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use a stronger password.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Contact support.';
      case 'requires-recent-login':
        return 'Please re-authenticate and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Authentication error: ${e.code}';
    }
  }

  // Small helper to show snackbars only when it's safe
  void _safeShowSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) return;
    AppSnackbar.show(context, message, isError: isError);
  }

  // Generic error handler that also shows your AppSnackbar safely
  void _handleFirebaseAuthError(
    BuildContext context,
    Object error, {
    String? fallback,
  }) {
    if (!context.mounted) return;

    if (error is FirebaseAuthException) {
      final msg = _friendlyFirebaseErrorMessage(error);
      _safeShowSnackbar(context, msg, isError: true);
    } else {
      _safeShowSnackbar(
        context,
        fallback ?? 'Something went wrong',
        isError: true,
      );
    }
  }

  // --- Auth operations ----------------------------------------------------

  /// Sign in with email & password.
  Future<User?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _safeShowSnackbar(context, 'Signed in successfully.');
      return cred.user;
    } on FirebaseAuthException catch (e) {
      final msg = _friendlyFirebaseErrorMessage(e);
      _safeShowSnackbar(context, msg, isError: true);

      // If no account exists for that email, send them to registration
      if (e.code == 'user-not-found') {
        await Future.delayed(const Duration(seconds: 1));
        if (!context.mounted) return null;
        Navigator.pushReplacementNamed(context, '/credentials');
      }

      return null; // prevent further navigation
    } catch (e) {
      _handleFirebaseAuthError(context, e, fallback: 'Sign in failed.');
      return null; // stop fall-through
    }
  }

  /// Register a new user (signup) with email & password.
  /// This sends an email verification immediately and returns the created user.
  Future<User?> registerUserWithEmail(
    BuildContext context,
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Optional display name update
      if (displayName != null && cred.user != null) {
        await cred.user!.updateDisplayName(displayName);
        await cred.user!.reload();
      }

      // Try sending verification email
      try {
        await cred.user?.sendEmailVerification();
        _safeShowSnackbar(context, 'Account created. Verification email sent.');
      } catch (sendErr) {
        _safeShowSnackbar(
          context,
          'Account created but verification email could not be sent.',
          isError: true,
        );
      }

      // Return user only if successful
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      final msg = _friendlyFirebaseErrorMessage(e);

      // Show error message
      _safeShowSnackbar(context, msg, isError: true);

      // Special handling for existing accounts
      if (e.code == 'email-already-in-use') {
        // Wait a beat to let the user see the snackbar
        await Future.delayed(const Duration(seconds: 1));

        if (!context.mounted) return null;

        // Navigate to Sign-In page
        context.pushReplacement('/sign_in');
      }

      return null; // Important: prevent navigation on error
    } catch (e) {
      _handleFirebaseAuthError(
        context,
        e,
        fallback: 'Account creation failed.',
      );
      return null; // Also prevent fall-through
    }
  }

  /// Send email verification to current user.
  Future<bool> sendEmailVerification(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _safeShowSnackbar(context, 'No user logged in.', isError: true);
        return false;
      }
      if (user.emailVerified) {
        _safeShowSnackbar(context, 'Email already verified.');
        return true;
      }
      await user.sendEmailVerification();
      _safeShowSnackbar(context, 'Verification email sent.');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(context, e);
      return false;
    } catch (e) {
      _handleFirebaseAuthError(
        context,
        e,
        fallback: 'Failed to send verification email.',
      );
      return false;
    }
  }

  /// Send password reset email.
  Future<bool> sendPasswordResetEmail(
    BuildContext context,
    String email,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _safeShowSnackbar(context, 'Password reset email sent.');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(context, e);
      return false;
    } catch (e) {
      _handleFirebaseAuthError(
        context,
        e,
        fallback: 'Failed to send password reset email.',
      );
      return false;
    }
  }

  /// Re-authenticate the current user using their current password.
  Future<bool> reauthenticateWithPassword(
    BuildContext context,
    String email,
    String currentPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _safeShowSnackbar(
          context,
          'No user to re-authenticate.',
          isError: true,
        );
        return false;
      }
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      _safeShowSnackbar(context, 'Re-authentication successful.');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(context, e);
      return false;
    } catch (e) {
      _handleFirebaseAuthError(
        context,
        e,
        fallback: 'Re-authentication failed.',
      );
      return false;
    }
  }

  Future<bool> updateEmail(
    BuildContext context,
    String newEmail, {
    String? currentPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _safeShowSnackbar(context, 'No user logged in.', isError: true);
        return false;
      }

      // Re-authenticate if password provided
      if (currentPassword != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email ?? '',
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Use the API that sends verification to the new email before switching
      await user.verifyBeforeUpdateEmail(newEmail.trim());
      await user.reload();

      _safeShowSnackbar(
        context,
        'Verification email sent to $newEmail. Please verify to update.',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(context, e);
      return false;
    } catch (e) {
      _handleFirebaseAuthError(context, e, fallback: 'Failed to update email.');
      return false;
    }
  }

  /// Update user password. If currentPassword is provided, will attempt re-auth automatically.
  Future<bool> updatePassword(
    BuildContext context,
    String newPassword, {
    String? currentPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _safeShowSnackbar(context, 'No user logged in.', isError: true);
        return false;
      }
      if (currentPassword != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email ?? '',
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      }
      await user.updatePassword(newPassword);
      _safeShowSnackbar(context, 'Password updated successfully.');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(context, e);
      return false;
    } catch (e) {
      _handleFirebaseAuthError(
        context,
        e,
        fallback: 'Failed to update password.',
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      _safeShowSnackbar(context, 'Signed out.');
    } catch (e) {
      _handleFirebaseAuthError(context, e, fallback: 'Failed to sign out.');
    }
  }

  Future<bool> deleteUser(
    BuildContext context, {
    String? currentPasswordForReauth,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _safeShowSnackbar(context, 'No user to delete.', isError: true);
        return false;
      }

      await user.delete();
      _safeShowSnackbar(context, 'Account deleted.');
      return true;
    } on FirebaseAuthException catch (e) {
      // Handle "requires-recent-login"
      if (e.code == 'requires-recent-login' &&
          currentPasswordForReauth != null) {
        final email = _auth.currentUser?.email ?? '';
        final reauthOk = await reauthenticateWithPassword(
          context,
          email,
          currentPasswordForReauth,
        );

        if (reauthOk) {
          final freshUser = _auth.currentUser;
          await freshUser?.delete();
          _safeShowSnackbar(
            context,
            'Account deleted after re-authentication.',
          );
          return true;
        } else {
          _safeShowSnackbar(context, 'Reauthentication failed.', isError: true);
          return false;
        }
      }

      _handleFirebaseAuthError(context, e);
      return false;
    } catch (e) {
      _handleFirebaseAuthError(
        context,
        e,
        fallback: 'Failed to delete account.',
      );
      return false;
    }
  }
}
