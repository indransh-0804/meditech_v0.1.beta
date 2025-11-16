import 'package:flutter/material.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/inventory/widgets/misc.dart';

class SalesSummaryCard extends StatelessWidget {
  final SalesSummaryData data;
  final List<double> weeklySales;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const SalesSummaryCard({
    super.key,
    required this.data,
    required this.weeklySales,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.h(8)),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.w(12)),
                child: SalesGraph(weeklySales: weeklySales),
              ),
            ),
            SizedBox(height: SizeConfig.h(8)),
            OverviewRow(
              data: OverviewRowData(
                label: "Yesterday's Sales",
                value: '₹${data.yesterdaySales.toStringAsFixed(0)}',
                icon: Icons.calendar_today_rounded,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: SizeConfig.h(16)),
            OverviewRow(
              data: OverviewRowData(
                label: "Weekly Sales",
                value: '₹${data.weeklyTotal.toStringAsFixed(0)}',
                icon: Icons.calendar_month_outlined,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
