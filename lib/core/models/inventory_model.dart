import 'package:flutter/material.dart';

class InfoTileData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconColor;

  InfoTileData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconColor,
  });
}

class OverviewRowData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  OverviewRowData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class StockSummaryData {
  final int expiredCount;
  final int outOfStockCount;
  final int lowStockCount;
  final int expiringSoonCount;
  final int totalMedicines;
  final String totalValue; // use string for formatted currency

  StockSummaryData({
    required this.expiredCount,
    required this.outOfStockCount,
    required this.lowStockCount,
    required this.expiringSoonCount,
    required this.totalMedicines,
    required this.totalValue,
  });
}

class LastRestockInfo {
  final String date;
  final String restockedBy;
  final int itemsRestocked;

  LastRestockInfo({
    required this.date,
    required this.restockedBy,
    required this.itemsRestocked,
  });
}

class InventoryOverviewData {
  final String lastRestockDate;
  final int medicinesOutOfStock;
  final int totalMedicines;
  final int lowStockCount;

  InventoryOverviewData({
    required this.lastRestockDate,
    required this.medicinesOutOfStock,
    required this.totalMedicines,
    required this.lowStockCount,
  });
}

class MedicineType {
  final String name;
  final int count;
  final IconData icon;

  MedicineType({required this.name, required this.count, required this.icon});

  MedicineType copyWith({String? name, int? count, IconData? icon}) {
    return MedicineType(
      name: name ?? this.name,
      count: count ?? this.count,
      icon: icon ?? this.icon,
    );
  }
}
