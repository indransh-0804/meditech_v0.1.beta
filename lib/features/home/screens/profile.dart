import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:rxdart/rxdart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final String? role;

  @override
  void initState() {
    super.initState();
    role = Hive.box("roleBox").get("role");
  }

  Stream<Map<String, dynamic>> combinedUserAndStore() {
    final uid = FirebaseAuthService.instance.currentUser?.uid;
    final userStream = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots();

    final storeStream = FirebaseFirestore.instance
        .collection("store")
        .doc("default_store")
        .snapshots();

    return Rx.combineLatest2(userStream, storeStream, (userSnap, storeSnap) {
      final userData = userSnap.data() ?? {};
      final storeData = storeSnap.data() ?? {};

      return {"user": userData, "store": storeData};
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuthService.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Not signed in")));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const AppBaar(header: "Profile", isBackable: true),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: combinedUserAndStore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No profile data found"));
          }

          final data = snapshot.data!;
          final user = data["user"];
          final store = data["store"];

          final location = store["location"] ?? {};
          final time = store["time"] ?? {};

          final userName = user["name"] ?? "--";
          final userEmail = user["email"] ?? "--";
          final userGender = user["gender"] ?? "--";
          final userAge = user["age"] ?? "--";
          final userContact = user["contact"] ?? "--";

          final storeName = store["name"] ?? "--";
          final storeEmail = store["email"] ?? "--";
          final storeAddress = location["address"] ?? "--";
          final storeAreaCode = location["area_code"] ?? "--";
          final storeCity = location["city"] ?? "--";
          final storeType = location["store_type"] ?? "--";
          final openTime = time["open"] ?? "--";
          final closeTime = time["close"] ?? "--";

          Widget personalDetails;
          switch (role) {
            case "owner":
              personalDetails = _buildInfoItem(
                Icons.phone_rounded,
                "Contact",
                userContact,
                context,
              );
              break;
            case "employee":
              personalDetails = Column(
                children: [
                  _buildInfoItem(
                    Icons.phone_rounded,
                    "Contact",
                    userContact,
                    context,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(Icons.cake_rounded, "Age", userAge, context),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    Icons.person_outline_rounded,
                    "Gender",
                    userGender,
                    context,
                  ),
                ],
              );
              break;
            default:
              personalDetails = const Center(
                child: Text("Role not recognized"),
              );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildSectionCard(
                  context,
                  title: "Personal Details",
                  child: personalDetails,
                ),

                const SizedBox(height: 16),

                _buildSectionCard(
                  context,
                  title: "Store Information",
                  child: Column(
                    children: [
                      _buildInfoItem(
                        Icons.storefront_rounded,
                        "Store Name",
                        storeName,
                        context,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        Icons.email_rounded,
                        "Email",
                        storeEmail,
                        context,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        Icons.location_on_rounded,
                        "Address",
                        storeAddress,
                        context,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        Icons.location_city_rounded,
                        "City",
                        storeCity,
                        context,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        Icons.pin_drop_rounded,
                        "Area Code",
                        storeAreaCode,
                        context,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        Icons.category_rounded,
                        "Type",
                        storeType,
                        context,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        Icons.schedule_rounded,
                        "Opens",
                        openTime,
                        context,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        Icons.schedule_rounded,
                        "Closes",
                        closeTime,
                        context,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.logout_rounded,
                        label: "Sign Out",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final colorScheme = Theme.of(context).colorScheme;
                              final textTheme = Theme.of(context).textTheme;

                              return AlertDialog(
                                backgroundColor: colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    SizeConfig.w(20),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.warning_outlined,
                                  color: colorScheme.error,
                                  size: SizeConfig.w(48),
                                ),
                                title: Text(
                                  'Sign Out!',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to sign out.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: Text(
                                      'Cancel',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await FirebaseAuthService.instance
                                            .signOut(context);
                                        Hive.box("roleBox").clear();
                                        Hive.box("auth").clear();
                                        context.go("/sign_in");
                                      } catch (e) {
                                        AppSnackbar.show(
                                          context,
                                          "Failed to Sign Out!, please try again",
                                          isError: true,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          colorScheme.errorContainer,
                                      foregroundColor:
                                          colorScheme.onErrorContainer,
                                    ),
                                    child: const Text('Sign Out'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        isDestructive: false,
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        context,
                        icon: Icons.delete_forever_rounded,
                        label: "Delete Account",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final colorScheme = Theme.of(context).colorScheme;
                              final textTheme = Theme.of(context).textTheme;

                              return AlertDialog(
                                backgroundColor: colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    SizeConfig.w(20),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.warning_outlined,
                                  color: colorScheme.error,
                                  size: SizeConfig.w(48),
                                ),
                                title: Text(
                                  'Delete Account!',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete your Account.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: Text(
                                      'Cancel',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await FirebaseAuthService.instance
                                            .deleteUser(context);
                                        Hive.box("roleBox").clear();
                                        Hive.box("auth").clear();
                                        context.go("/intro");
                                      } catch (e) {
                                        AppSnackbar.show(
                                          context,
                                          "Failed to delete the account!, please try again",
                                          isError: true,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          colorScheme.errorContainer,
                                      foregroundColor:
                                          colorScheme.onErrorContainer,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDestructive,
  }) {
    return Material(
      color: isDestructive
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDestructive
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
