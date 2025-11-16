import 'package:flutter/material.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/inventory/widgets/inventory_control.dart';
import 'package:meditech_v1/features/inventory/widgets/inventory_summary.dart';
import 'package:meditech_v1/features/inventory/widgets/medicine_type.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late final String? role;

  @override
  void initState() {
    super.initState();
    role = Hive.box("roleBox").get("role");
  }

  @override
  Widget build(BuildContext context) {
    Widget additionalCard;
    switch (role) {
      case "owner":
        additionalCard = const SizedBox.shrink();
        break;
      case "employee":
        additionalCard = const InventoryControllCard();
        break;
      default:
        additionalCard = const Center(
          child: Text("Roles unrecognized: some features may not appear"),
        );
    }

    return Scaffold(
      appBar: const AppBaar(header: "Dashboard", isBackable: true),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: SizeConfig.w(8),
          vertical: SizeConfig.h(8),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                additionalCard,
                const Header(header: "Inventory Analytics"),
                FutureBuilder(
                  future: fetchStockSummary(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return StockSummaryCard(data: snapshot.data!);
                  },
                ),
                const Header(header: "Stock Categories"),
                const MedicineTypeCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
