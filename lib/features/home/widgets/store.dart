import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditech_v1/core/core.dart';

class StoreStatusCard extends StatefulWidget {
  const StoreStatusCard({super.key});

  @override
  State<StoreStatusCard> createState() => StoreStatusCardState();
}

class StoreStatusCardState extends State<StoreStatusCard> {
  int? employees;
  int? owners;
  bool? isOpen;

  @override
  void initState() {
    super.initState();
    employeeCount();
    ownerCount();
    checkStoreStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final open = isOpen ?? false; // default false until loaded
    final statusColor = open ? Colors.green : Colors.redAccent;
    final statusText = open ? "OPEN" : "CLOSED";

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATUS ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Store Status",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(statusText, statusColor),
              ],
            ),

            SizedBox(height: SizeConfig.h(16)),
            Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
            SizedBox(height: SizeConfig.h(16)),

            // INFO ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildInfoBlock(
                    context,
                    icon: Icons.people_outline,
                    label: "Employees Working",
                    value: employees?.toString() ?? "--",
                  ),
                ),
                Expanded(
                  child: _buildInfoBlock(
                    context,
                    icon: Icons.person_outline,
                    label: "Owners Registered",
                    value: owners?.toString() ?? "--",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(12),
        vertical: SizeConfig.h(6),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Container(
            width: SizeConfig.w(8),
            height: SizeConfig.w(8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: SizeConfig.w(8)),
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> employeeCount() async {
    final snap = await FirebaseFirestore.instance
        .collection("store")
        .doc("default_store")
        .collection("employees")
        .count()
        .get();

    setState(() => employees = snap.count);
  }

  Future<void> ownerCount() async {
    final snap = await FirebaseFirestore.instance
        .collection("store")
        .doc("default_store")
        .collection("owners")
        .count()
        .get();

    setState(() => owners = snap.count);
  }

  Future<void> checkStoreStatus() async {
    final doc = await FirebaseFirestore.instance
        .collection("store")
        .doc("default_store")
        .get();

    if (!doc.exists) {
      setState(() => isOpen = false);
      return;
    }

    final data = doc.data()!;
    final open = data["time"]["open"]; // ex: "09:00"
    final close = data["time"]["close"]; // ex: "21:30"

    final now = TimeOfDay.now();

    bool isBetween(String start, String end, TimeOfDay current) {
      int toMin(String t) {
        final parts = t.split(":");
        return int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }

      final currentMin = current.hour * 60 + current.minute;
      return toMin(start) <= currentMin && currentMin <= toMin(end);
    }

    setState(() => isOpen = isBetween(open, close, now));
  }
}

Widget _buildInfoBlock(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(8)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.w(8),
                vertical: SizeConfig.h(8),
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SizeConfig.w(12)),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: SizeConfig.h(22),
              ),
            ),
            SizedBox(width: SizeConfig.w(16)),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(4)),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: SizeConfig.h(4)),
      ],
    ),
  );
}
