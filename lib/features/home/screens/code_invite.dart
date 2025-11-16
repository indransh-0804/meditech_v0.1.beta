import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditech_v1/core/core.dart';

class InviteCodeScreen extends StatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  State<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends State<InviteCodeScreen> {
  String? storeName;
  String? inviteCode;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    final storeRef = FirebaseFirestore.instance
        .collection('store')
        .doc('default_store');

    try {
      final snapshot = await storeRef.get();

      if (!snapshot.exists) {
        AppSnackbar.show(context, "Store not found", isError: true);
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        storeName = data['name']?.toString().trim() ?? "Store";
        inviteCode = data['invite_code']?.toString().trim() ?? "------";
      });
    } catch (e) {
      AppSnackbar.show(context, "Something went wrong", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppBaar(header: "Store Invite Code", isBackable: true),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(16),
          vertical: SizeConfig.h(16),
        ),
        child: storeName == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Container(
                  padding: EdgeInsets.all(SizeConfig.w(24)),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: SizeConfig.w(64),
                        color: colorScheme.primary,
                      ),
                      SizedBox(height: SizeConfig.h(16)),
                      Text(
                        storeName!,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(32)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.w(24),
                          vertical: SizeConfig.h(16),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              inviteCode!,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: SizeConfig.w(8)),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: inviteCode!),
                                );
                                AppSnackbar.show(
                                  context,
                                  "Invite code copied!",
                                );
                              },
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
  }
}
