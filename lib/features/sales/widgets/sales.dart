import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:meditech_v1/core/core.dart';
import 'package:meditech_v1/features/inventory/widgets/misc.dart';

class SalesDetailedCard extends StatelessWidget {
  final SalesSummaryData data;
  final List<double> weeklySales;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const SalesDetailedCard({
    super.key,
    required this.data,
    required this.weeklySales,
    required this.colorScheme,
    required this.textTheme,
  });

  double _calculateTrend() {
    if (weeklySales.length < 2) return 0;
    final recent = weeklySales.sublist((weeklySales.length / 2).ceil());
    final older = weeklySales.sublist(0, (weeklySales.length / 2).ceil());
    final avgRecent = recent.fold(0.0, (a, b) => a + b) / recent.length;
    final avgOlder = older.fold(0.0, (a, b) => a + b) / older.length;
    return avgOlder == 0 ? 0 : ((avgRecent - avgOlder) / avgOlder) * 100;
  }

  double _getHighest() =>
      weeklySales.isNotEmpty ? weeklySales.reduce((a, b) => a > b ? a : b) : 0;
  double _getLowest() =>
      weeklySales.isNotEmpty ? weeklySales.reduce((a, b) => a < b ? a : b) : 0;
  double _getAverage() => weeklySales.isNotEmpty
      ? weeklySales.fold(0.0, (a, b) => a + b) / weeklySales.length
      : 0;

  @override
  Widget build(BuildContext context) {
    final trend = _calculateTrend();
    final highest = _getHighest();
    final lowest = _getLowest();
    final average = _getAverage();
    final isTrendingUp = trend >= 0;

    return Card(
      elevation: 6,
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
            // Graph in a card container
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
            SizedBox(height: SizeConfig.h(12)),
            Divider(color: colorScheme.outlineVariant),
            SizedBox(height: SizeConfig.h(12)),
            // Summary Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: SizeConfig.h(8),
              crossAxisSpacing: SizeConfig.w(8),
              childAspectRatio: 1.8,
              children: [
                _StatTile(
                  label: "Avg Sales",
                  value: '₹${average.toStringAsFixed(0)}',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                _StatTile(
                  label: "Peak Sales",
                  value: '₹${highest.toStringAsFixed(0)}',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                _StatTile(
                  label: "Low Sales",
                  value: '₹${lowest.toStringAsFixed(0)}',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                _TrendTile(
                  value:
                      '${isTrendingUp ? '+' : ''}${trend.toStringAsFixed(1)}%',
                  isPositive: isTrendingUp,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ],
            ),
            SizedBox(height: SizeConfig.h(12)),
            Divider(color: colorScheme.outlineVariant),
            SizedBox(height: SizeConfig.h(12)),
            OverviewRow(
              data: OverviewRowData(
                label: "Yesterday's Sales",
                value: '₹${data.yesterdaySales.toStringAsFixed(0)}',
                icon: Icons.calendar_today_rounded,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: SizeConfig.h(10)),
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _StatTile({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.w(8)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SizeConfig.w(8)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: SizeConfig.h(4)),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendTile extends StatelessWidget {
  final String value;
  final bool isPositive;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _TrendTile({
    required this.value,
    required this.isPositive,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.all(SizeConfig.w(8)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SizeConfig.w(8)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: SizeConfig.h(4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: SizeConfig.w(14),
                color: trendColor,
              ),
              SizedBox(width: SizeConfig.w(4)),
              Text(
                'Trend',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DailySalesCard extends StatelessWidget {
  final List<DailySalesData> allSalesData;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChange;
  final ColorScheme colorScheme;

  const DailySalesCard({
    super.key,
    required this.allSalesData,
    required this.selectedDate,
    required this.onDateChange,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final selectedData = allSalesData.firstWhere(
      (d) => DateUtils.isSameDay(d.date, selectedDate),
      orElse: () => DailySalesData(date: selectedDate, items: []),
    );

    return Card(
      elevation: 4,
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
            _datePicker(),
            SizedBox(height: SizeConfig.h(16)),
            _salesList(selectedData),
          ],
        ),
      ),
    );
  }

  Widget _datePicker() => EasyDateTimeLinePicker(
    firstDate: DateTime.now().subtract(const Duration(days: 8)),
    lastDate: DateTime.now().subtract(const Duration(days: 1)),
    focusedDate: selectedDate,
    selectionMode: const SelectionMode.autoCenter(),
    headerOptions: const HeaderOptions(headerType: HeaderType.none),
    timelineOptions: TimelineOptions(height: SizeConfig.h(95)),
    onDateChange: onDateChange,
  );

  Widget _salesList(DailySalesData data) {
    if (data.items.isEmpty) {
      return const Center(
        child: Text(
          'No sales recorded for this date.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: SizeConfig.h(260),
      child: ListView.separated(
        itemCount: data.items.length,
        separatorBuilder: (_, __) => SizedBox(height: SizeConfig.h(10)),
        itemBuilder: (context, index) {
          final sale = data.items[index];
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                sale.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Qty: ${sale.quantity} | ₹${sale.amount.toStringAsFixed(2)}',
              ),
              trailing: Text(
                '₹${sale.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: SizeConfig.h(15),
                  color: Colors.green,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
