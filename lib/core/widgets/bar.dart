import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditech_v1/core/core.dart';

class AppBaar extends StatefulWidget implements PreferredSizeWidget {
  final String header;
  final bool isBackable;
  final VoidCallback? onNotificationsTap;

  const AppBaar({
    super.key,
    this.header = "MediTech",
    this.isBackable = true,
    this.onNotificationsTap,
  });

  @override
  State<AppBaar> createState() => _AppBaarState();

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _AppBaarState extends State<AppBaar> {
  late String? role;

  @override
  void initState() {
    super.initState();
    role = Hive.box("roleBox").get("role");
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget menu;
    switch (role) {
      case "owner":
        menu = const OwnerMenu();
        break;
      case "employee":
        menu = const EmployeeMenu();
        break;
      default:
        menu = const Center(child: Text("Roles not recognized"));
    }

    return Container(
      decoration: BoxDecoration(color: colorScheme.surface),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(16),
        vertical: SizeConfig.h(12),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.isBackable
                    ? InkWell(
                        onTap: () => context.pop(),
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          size: SizeConfig.w(24),
                          color: colorScheme.onSurface,
                        ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(width: SizeConfig.w(8)),
                Text(
                  widget.header,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => context.push("/profile"),
                  child: Icon(
                    Icons.person_outlined,
                    size: SizeConfig.w(24),
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: SizeConfig.w(8)),
                menu,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerMenu extends StatefulWidget {
  const OwnerMenu({super.key});

  @override
  State<OwnerMenu> createState() => _OwnerMenuState();
}

class _OwnerMenuState extends State<OwnerMenu> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MenuAnchor(
      controller: _menuController,
      builder: (context, controller, child) {
        return InkWell(
          onTap: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          child: Icon(
            Icons.menu_rounded,
            size: SizeConfig.w(24),
            color: colorScheme.onSurface,
          ),
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            _menuController.close();
            context.go("/dashboard");
          },
          leadingIcon: Icon(Icons.dashboard, color: colorScheme.primary),
          child: const Text('Dashboard'),
        ),

        MenuItemButton(
          onPressed: () {
            _menuController.close();
            context.push("/sales");
          },
          leadingIcon: Icon(
            Icons.trending_up_rounded,
            color: colorScheme.primary,
          ),
          child: const Text('Sales'),
        ),
        MenuItemButton(
          onPressed: () {
            _menuController.close();
            context.push("/inventory");
          },
          leadingIcon: Icon(Icons.inventory, color: colorScheme.primary),
          child: const Text('Inventory'),
        ),

        MenuItemButton(
          onPressed: () {
            _menuController.close();
            context.push("/invite_code");
          },
          leadingIcon: Icon(Icons.code_rounded, color: colorScheme.primary),
          child: const Text('Invite Code'),
        ),

        const Divider(),

        MenuItemButton(
          onPressed: () {
            _menuController.close();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final colorScheme = Theme.of(context).colorScheme;
                final textTheme = Theme.of(context).textTheme;

                return AlertDialog(
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.w(20)),
                  ),
                  icon: Icon(
                    Icons.warning_outlined,
                    color: colorScheme.error,
                    size: SizeConfig.w(48),
                  ),
                  title: Text(
                    'Sign Out!',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to sign out.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Cancel',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuthService.instance.signOut(context);
                          Hive.box("roleBox").clear();
                          Hive.box("auth").clear();
                          context.go("/sign_in");
                          AppSnackbar.show(context, "Signed Out Successfully!");
                        } catch (e) {
                          AppSnackbar.show(
                            context,
                            "Failed to Sign Out!, please try again",
                            isError: true,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.onErrorContainer,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                );
              },
            );
          },
          leadingIcon: Icon(Icons.logout, color: colorScheme.error),
          child: Text('Logout', style: TextStyle(color: colorScheme.error)),
        ),
      ],
    );
  }
}

class EmployeeMenu extends StatefulWidget {
  const EmployeeMenu({super.key});

  @override
  State<EmployeeMenu> createState() => _EmployeeMenuState();
}

class _EmployeeMenuState extends State<EmployeeMenu> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MenuAnchor(
      controller: _menuController,
      builder: (context, controller, child) {
        return InkWell(
          onTap: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          child: Icon(
            Icons.menu_rounded,
            size: SizeConfig.w(24),
            color: colorScheme.onSurface,
          ),
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            _menuController.close();
            context.go("/dashboard");
          },
          leadingIcon: Icon(Icons.dashboard, color: colorScheme.primary),
          child: const Text('Dashboard'),
        ),

        MenuItemButton(
          onPressed: () {
            _menuController.close();
            context.push("/billing");
          },
          leadingIcon: Icon(
            Icons.trending_up_rounded,
            color: colorScheme.primary,
          ),
          child: const Text('Billing'),
        ),

        MenuItemButton(
          onPressed: () {
            _menuController.close();
            context.push("/inventory");
          },
          leadingIcon: Icon(Icons.inventory, color: colorScheme.primary),
          child: const Text('Inventory'),
        ),

        const Divider(),

        MenuItemButton(
          onPressed: () {
            _menuController.close();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final colorScheme = Theme.of(context).colorScheme;
                final textTheme = Theme.of(context).textTheme;

                return AlertDialog(
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.w(20)),
                  ),
                  icon: Icon(
                    Icons.warning_outlined,
                    color: colorScheme.error,
                    size: SizeConfig.w(48),
                  ),
                  title: Text(
                    'Sign Out!',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to sign out.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Cancel',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuthService.instance.signOut(context);
                          Hive.box("roleBox").clear();
                          context.go("/sign_in");
                          AppSnackbar.show(context, "Signed Out Successfully!");
                        } catch (e) {
                          AppSnackbar.show(
                            context,
                            "Failed to Sign Out!, please try again",
                            isError: true,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.onErrorContainer,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                );
              },
            );
          },
          leadingIcon: Icon(Icons.logout, color: colorScheme.error),
          child: Text('Logout', style: TextStyle(color: colorScheme.error)),
        ),
      ],
    );
  }
}
