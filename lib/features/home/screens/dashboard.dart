import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/auth/screens/signup/employee_shift.dart';
import 'package:meditech_v1/features/home/widgets/inventory_overview.dart';
import 'package:meditech_v1/features/home/widgets/profile.dart';
import 'package:meditech_v1/features/home/widgets/sales_summary.dart';
import 'package:meditech_v1/features/home/widgets/store.dart';
import 'package:meditech_v1/features/home/widgets/workspace.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final String? role;

  @override
  void initState() {
    super.initState();
    role = Hive.box("roleBox").get("role");
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (role) {
      case "owner":
        body = const OwnerDashboard();
        break;
      case "employee":
        body = const EmployeeDashboard();
        break;
      default:
        body = const Center(child: Text("Roles not recognized"));
    }

    return Scaffold(
      appBar: const AppBaar(header: "Dashboard", isBackable: false),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: SizeConfig.w(8),
          vertical: SizeConfig.h(8),
        ),
        child: SafeArea(child: SingleChildScrollView(child: body)),
      ),
    );
  }
}

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final String _storeId = "default_store";

  Future<(SalesSummaryData, List<DailySalesData>)> fetchSales() async {
    final billingRef = FirebaseFirestore.instance
        .collection("store")
        .doc(_storeId)
        .collection("billing");

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

    final dailySales = grouped.entries
        .map((entry) => DailySalesData(date: entry.key, items: entry.value))
        .toList();

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const UserProfileCard(),
        SizedBox(height: SizeConfig.h(8)),
        const StoreStatusCard(),
        SizedBox(height: SizeConfig.h(8)),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sales Summary",
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () => context.push("/sales"),
                child: Text(
                  "See More",
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: SizeConfig.h(8)),

        FutureBuilder(
          future: fetchSales(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final (summary, _) = snapshot.data!;
            return SalesSummaryCard(
              data: summary,
              weeklySales: const [0, 0, 0, 0, 0, 0, 0], // replace if needed
              colorScheme: colorScheme,
              textTheme: textTheme,
            );
          },
        ),

        SizedBox(height: SizeConfig.h(8)),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Inventory Overview",
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () {
                  context.push("/inventory");
                },
                child: Text(
                  "See More",
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        FutureBuilder(
          future: fetchInventoryOverview(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Text("No inventory data available");
            }

            return InventoryOverviewCard(data: snapshot.data!);
          },
        ),
      ],
    );
  }
}

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const UserProfileCard(),
        SizedBox(height: SizeConfig.h(8)),
        Padding(
          padding: EdgeInsets.only(left: SizeConfig.w(16)),
          child: Text(
            "Shift Status",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        EmployeeShiftCard(onClockIn: (time) {}, onClockOut: (time) {}),
        SizedBox(height: SizeConfig.h(8)),
        Padding(
          padding: EdgeInsets.only(left: SizeConfig.w(16)),
          child: Text(
            "Your workspace",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        const PrimaryActionsWidget(),
      ],
    );
  }
}
