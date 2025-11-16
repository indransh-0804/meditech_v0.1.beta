import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditech_v1/core/core.dart';

class MedicineType {
  final String name;
  final int count;
  final IconData icon;

  MedicineType({required this.name, required this.count, required this.icon});

  MedicineType copyWith({int? count}) {
    return MedicineType(name: name, count: count ?? this.count, icon: icon);
  }
}

class MedicineTypeCard extends StatelessWidget {
  const MedicineTypeCard({super.key});

  Future<List<MedicineType>> _fetchMedicineTypeCounts() async {
    final types = [
      MedicineType(name: 'Tablets', count: 0, icon: Icons.medication),
      MedicineType(name: 'Syrups', count: 0, icon: Icons.local_drink),
      MedicineType(name: 'Injections', count: 0, icon: Icons.vaccines),
      MedicineType(name: 'Capsules', count: 0, icon: Icons.medication_liquid),
      MedicineType(name: 'Ointments', count: 0, icon: Icons.healing),
      MedicineType(name: 'Drops', count: 0, icon: Icons.water_drop),
    ];

    for (int i = 0; i < types.length; i++) {
      final snap = await FirebaseFirestore.instance
          .collection("store")
          .doc("default_store")
          .collection("medicine")
          .where("type", isEqualTo: types[i].name)
          .count()
          .get();

      types[i] = types[i].copyWith(count: snap.count);
    }

    return types;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<MedicineType>>(
      future: _fetchMedicineTypeCounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final medicineTypes = snapshot.data!;

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
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: medicineTypes.length,
              itemBuilder: (context, index) {
                final type = medicineTypes[index];

                return Container(
                  padding: EdgeInsets.all(SizeConfig.w(16)),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            type.icon,
                            color: colorScheme.secondary,
                            size: SizeConfig.w(32),
                          ),
                          SizedBox(width: SizeConfig.w(8)),
                          Text(
                            type.count.toString(),
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig.h(8)),
                      Text(
                        type.name,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
