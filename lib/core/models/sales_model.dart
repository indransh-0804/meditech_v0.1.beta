class SalesSummaryData {
  final double yesterdaySales;
  final double weeklyTotal;

  SalesSummaryData({required this.yesterdaySales, required this.weeklyTotal});
}

class DailySaleItem {
  final String name;
  final int quantity;
  final double amount;

  DailySaleItem({
    required this.name,
    required this.quantity,
    required this.amount,
  });
}

class DailySalesData {
  final DateTime date;
  final List<DailySaleItem> items;

  DailySalesData({required this.date, required this.items});
}
