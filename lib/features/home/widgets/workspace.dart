import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditech_v1/core/core.dart';

class PrimaryActionsWidget extends StatelessWidget {
  const PrimaryActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(8),
        vertical: SizeConfig.h(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FullActionButton(
            icon: Icons.receipt_long_rounded,
            label: 'Billing',
            subtitle: 'Create & Manage invoices',
            onTap: () {
              context.push("/billing");
            },
            textTheme: textTheme,
            backgroundColor: colorScheme.primaryContainer,
            iconColor: colorScheme.onPrimaryContainer,
            textColor: colorScheme.onPrimaryContainer,
          ),
          SizedBox(height: SizeConfig.h(8)),
          Row(
            children: [
              Expanded(
                child: HalfActionButton(
                  icon: Icons.inventory_rounded,
                  label: 'Inventory',
                  subtitle: 'Manage stocks',
                  onTap: () {
                    context.push("/inventory");
                  },
                  textTheme: Theme.of(context).textTheme,
                  backgroundColor: colorScheme.secondaryContainer,
                  iconColor: colorScheme.onSecondaryContainer,
                  textColor: colorScheme.onSecondaryContainer,
                ),
              ),
              SizedBox(width: SizeConfig.w(8)),
              Expanded(
                child: HalfActionButton(
                  icon: Icons.local_shipping_rounded,
                  label: 'Supplier',
                  subtitle: 'Vendor relations',
                  onTap: () {
                    AppSnackbar.show(context, "Feature Unavailable!");
                  },
                  textTheme: Theme.of(context).textTheme,
                  backgroundColor: colorScheme.secondaryContainer,
                  iconColor: colorScheme.onSecondaryContainer,
                  textColor: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
