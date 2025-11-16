import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditech_v1/core/services/firebase_services.dart';

class FormValidators {
  static String? email(String? email) {
    final value = email?.trim();
    if (value == null || value.isEmpty) return "Email is required";
    if (!RegExp(r'^[\w.-]+@[a-zA-Z\d.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? password) {
    final value = password?.trim();
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 8) return "Password must be at least 8 characters";
    // Optional: Enforce stronger password
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).+$').hasMatch(value)) {
      return "Include upper, lower case letters, and a number";
    }
    return null;
  }

  static String? confirmPassword(String? confirmPassword, String? password) {
    final confirm = confirmPassword?.trim();
    final pass = password?.trim();
    if (confirm == null || confirm.isEmpty) return "Please confirm password";
    if (confirm != pass) return "Passwords do not match";
    return null;
  }

  static String? name(String? name) {
    final value = name?.trim();
    if (value == null || value.isEmpty) return "Name is required";
    if (value.length < 2) return "Name must be at least 2 characters";
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "Name must contain only letters";
    }
    return null;
  }

  static String? age(int? age) {
    if (age == null) return "Age is required";
    if (age <= 0 || age > 120) return "Please enter a valid age";
    return null;
  }

  static String? number(int? number) {
    if (number == null) return "This Field is required";
    return null;
  }

  static String? dob(DateTime? date) {
    if (date == null) return "Please select your DOB";
    final now = DateTime.now();
    int age = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    if (age < 16) return "You must be at least 16 years old";
    if (age > 120) return "Please enter a valid DOB";
    return null;
  }

  static String? contact(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return "Contact number is required";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
      return "Must be exactly 10 digits";
    }
    return null;
  }

  static String? areaCode(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return "Pincode is required";
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(v)) {
      return "Enter a valid 6-digit pincode";
    }
    return null;
  }

  static String? address(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return "Address is required";
    if (v.length < 10) return "Please provide a more detailed address";
    return null;
  }

  static String? inviteCode(String? value) {
    if (value == null || value.isEmpty) return "Invite code is required.";
    if (value.length != 8) return "Invite code must be 8 characters.";
    return null;
  }

  static Future<String?> validateInviteCode(String inviteCode) async {
    final firestore = FirebaseFirestore.instance;

    if (inviteCode.isEmpty) {
      return "Invite code is required.";
    }

    final query = await firestore
        .collection('stores')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return "Invalid invite code. Please check with the store owner.";
    }

    final storeDoc = query.docs.first;
    final employees = storeDoc.reference.collection('employees');

    // Optional: Prevent duplicate join requests
    final userId = FirebaseAuthService.instance.currentUser!.uid;
    final existing = await employees.doc(userId).get();
    if (existing.exists) {
      return "You’ve already requested to join this store.";
    }

    return null;
  }

  static String? gstin(String? value) {
    final v = value?.trim().toUpperCase();
    if (v == null || v.isEmpty) return "GSTIN is required";
    if (!RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    ).hasMatch(v)) {
      return "Enter a valid GSTIN (e.g., 22AAAAA0000A1Z5)";
    }
    return null;
  }
}
