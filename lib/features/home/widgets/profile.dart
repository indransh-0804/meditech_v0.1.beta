import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditech_v1/core/services/firebase_services.dart';
import 'package:meditech_v1/core/utils/size_config.dart';

class UserProfileCard extends StatefulWidget {
  const UserProfileCard({super.key});

  @override
  State<UserProfileCard> createState() => UserProfileCardState();
}

class UserProfileCardState extends State<UserProfileCard> {
  String? name;
  String? email;
  String? role;
  String? storeName;

  Future<void> getStoreName() async {
    final storeSnapshot = await FirebaseFirestore.instance
        .collection("store")
        .doc("default_store")
        .get();

    if (storeSnapshot.exists) {
      final data = storeSnapshot.data()!;
      setState(() {
        storeName = data["name"];
      });
    }
  }

  Future<void> getUserDetails() async {
    final String uid = FirebaseAuthService.instance.currentUser!.uid;
    final storeSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (storeSnapshot.exists) {
      final data = storeSnapshot.data()!;
      setState(() {
        name = data["name"];
        email = data["email"];
        role = data["role"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getStoreName();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final text = theme.textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(16),
          vertical: SizeConfig.h(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name ?? "Unavailable",
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: SizeConfig.h(4)),
            Text(
              email ?? "Unavailable",
              style: text.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: SizeConfig.h(8)),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
            SizedBox(height: SizeConfig.h(8)),
            Wrap(
              spacing: SizeConfig.w(8),
              runSpacing: SizeConfig.h(8),
              children: [
                _buildBadge(
                  context,
                  icon: Icons.badge_outlined,
                  label: role ?? "Unavailable",
                  bg: colorScheme.secondaryContainer,
                  fg: colorScheme.onSecondaryContainer,
                ),
                _buildBadge(
                  context,
                  icon: Icons.storefront_outlined,
                  label: storeName ?? "Unavailable",
                  bg: colorScheme.tertiaryContainer,
                  fg: colorScheme.onTertiaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(12),
        vertical: SizeConfig.h(6),
      ),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(SizeConfig.w(24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          SizedBox(width: SizeConfig.w(5)),
          Flexible(
            child: Text(
              label,
              style: text.bodySmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}
