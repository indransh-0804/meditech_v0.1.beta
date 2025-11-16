import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/inventory/widgets/misc.dart';

Future<StockSummaryData> fetchStockSummary() async {
  final snapshot = await FirebaseFirestore.instance
      .collection("store")
      .doc("default_store")
      .collection("medicine")
      .get();

  int expired = 0;
  int outOfStock = 0;
  int lowStock = 0;
  int expiringSoon = 0;
  double totalValue = 0;

  final now = DateTime.now();
  final soonThreshold = now.add(const Duration(days: 30));

  for (var doc in snapshot.docs) {
    final data = doc.data();

    final qty = data["quantity"] ?? 0;
    final price = double.tryParse(data["price"]?.toString() ?? "0") ?? 0;

    DateTime? expiry;
    if (data["expiry"] is Timestamp) {
      expiry = (data["expiry"] as Timestamp).toDate();
    }

    if (expiry != null && expiry.isBefore(now)) {
      expired++;
    }

    if (qty == 0) {
      outOfStock++;
    } else if (qty > 0 && qty < 10) {
      lowStock++;
    }

    if (expiry != null &&
        expiry.isAfter(now) &&
        expiry.isBefore(soonThreshold)) {
      expiringSoon++;
    }

    totalValue += qty * price;
  }

  return StockSummaryData(
    expiredCount: expired,
    outOfStockCount: outOfStock,
    lowStockCount: lowStock,
    expiringSoonCount: expiringSoon,
    totalMedicines: snapshot.docs.length,
    totalValue: "₹${totalValue.toStringAsFixed(2)}",
  );
}

class StockSummaryCard extends StatelessWidget {
  final StockSummaryData data;

  const StockSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    InfoTileData tileData({
      required IconData icon,
      required String label,
      required String value,
      required Color color,
      required Color iconColor,
    }) => InfoTileData(
      icon: icon,
      label: label,
      value: value,
      color: color,
      iconColor: iconColor,
    );

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoTile(
                  data: tileData(
                    icon: Icons.dangerous_rounded,
                    label: "Expired",
                    value: data.expiredCount.toString(),
                    color: Colors.redAccent,
                    iconColor: Colors.red,
                  ),
                ),
                InfoTile(
                  data: tileData(
                    icon: Icons.cancel_rounded,
                    label: "Out of Stock",
                    value: data.outOfStockCount.toString(),
                    color: Colors.redAccent,
                    iconColor: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.h(8)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoTile(
                  data: tileData(
                    icon: Icons.warning_amber_rounded,
                    label: "Low Stock",
                    value: data.lowStockCount.toString(),
                    color: Colors.orangeAccent,
                    iconColor: Colors.orange,
                  ),
                ),
                InfoTile(
                  data: tileData(
                    icon: Icons.schedule_rounded,
                    label: "Expiring Soon",
                    value: data.expiringSoonCount.toString(),
                    color: Colors.orangeAccent,
                    iconColor: Colors.orange,
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.h(8)),
            Divider(color: colorScheme.outlineVariant),
            SizedBox(height: SizeConfig.h(8)),

            OverviewRow(
              data: OverviewRowData(
                icon: Icons.medication_rounded,
                label: 'Total Medicines',
                value: data.totalMedicines.toString(),
                color: Colors.blue,
              ),
            ),
            SizedBox(height: SizeConfig.h(8)),
            OverviewRow(
              data: OverviewRowData(
                icon: Icons.currency_rupee_rounded,
                label: 'Total Value',
                value: data.totalValue,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
