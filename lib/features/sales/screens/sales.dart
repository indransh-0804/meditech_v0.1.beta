import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/sales/widgets/sales.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));

  Future<(SalesSummaryData, List<DailySalesData>)> fetchSales() async {
    final billingRef = FirebaseFirestore.instance
        .collection("store")
        .doc("default_store")
        .collection("sales");

    final snapshot = await billingRef
        .orderBy("createdAt", descending: true)
        .get();

    Map<DateTime, List<DailySaleItem>> grouped = {};
    double yesterdaySales = 0;
    double weeklyTotal = 0;

    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data["createdAt"] as Timestamp;
      final date = DateTime(
        timestamp.toDate().year,
        timestamp.toDate().month,
        timestamp.toDate().day,
      );

      final items = (data["items"] as List<dynamic>).map((raw) {
        return DailySaleItem(
          name: raw["name"],
          quantity: raw["quantity"],
          amount: (raw["amount"] as num).toDouble(),
        );
      }).toList();

      grouped.putIfAbsent(date, () => []);
      grouped[date]!.addAll(items);

      final billTotal = (data["totalAmount"] as num).toDouble();

      if (date == yesterday) yesterdaySales += billTotal;
      if (now.difference(date).inDays <= 7) weeklyTotal += billTotal;
    }

    final dailySales = grouped.entries.map((entry) {
      return DailySalesData(date: entry.key, items: entry.value);
    }).toList();

    final summary = SalesSummaryData(
      yesterdaySales: yesterdaySales,
      weeklyTotal: weeklyTotal,
    );

    return (summary, dailySales);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppBaar(header: "Sales", isBackable: true),
      body: FutureBuilder(
        future: fetchSales(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final (summary, allSalesData) = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.w(8),
              vertical: SizeConfig.h(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: SizeConfig.h(8)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
                  child: Text(
                    "Sales Analytics",
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.8,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                SizedBox(height: SizeConfig.h(8)),

                SalesDetailedCard(
                  data: summary,
                  weeklySales: const [0, 0, 0, 0, 0, 0, 0],
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),

                SizedBox(height: SizeConfig.h(16)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
                  child: Text(
                    "Daily Sales Log",
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.8,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.h(8)),

                DailySalesCard(
                  allSalesData: allSalesData,
                  selectedDate: _selectedDate,
                  onDateChange: (date) => setState(() => _selectedDate = date),
                  colorScheme: colorScheme,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
