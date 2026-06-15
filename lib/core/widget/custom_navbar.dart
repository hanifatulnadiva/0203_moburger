import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart';

enum TabKey { home, dashboard, order, menu, cart, report, profile }

class CustomBottomBar extends StatelessWidget {
  final TabKey activeTab;
  final String userRole; 
  final ValueChanged<TabKey> onTabPress;

  const CustomBottomBar({
    super.key,
    required this.activeTab,
    required this.userRole,
    required this.onTabPress,
  });

  List<Map<String, dynamic>> _getNavItems() {
    if (userRole == 'admin') {
      return [
        {'key': TabKey.dashboard, 'label': 'Dashboard', 'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard},
        {'key': TabKey.order, 'label': 'Order', 'icon': Icons.shopping_bag_outlined, 'activeIcon': Icons.shopping_bag},
        {'key': TabKey.menu, 'label': 'Menu', 'icon': Icons.restaurant_menu_outlined, 'activeIcon': Icons.restaurant_menu},
        {'key': TabKey.report, 'label': 'Report', 'icon': Icons.bar_chart_outlined, 'activeIcon': Icons.bar_chart},
        {'key': TabKey.profile, 'label': 'Profile', 'icon': Icons.person_outline, 'activeIcon': Icons.person},
      ];
    } else {
      return [
        {'key': TabKey.home, 'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
        {'key': TabKey.menu, 'label': 'Menu', 'icon': Icons.restaurant_menu_outlined, 'activeIcon': Icons.restaurant_menu},
        {'key': TabKey.cart, 'label': 'Cart', 'icon': Icons.shopping_cart_outlined, 'activeIcon': Icons.shopping_cart},
        {'key': TabKey.order, 'label': 'Order', 'icon': Icons.receipt_long_outlined, 'activeIcon': Icons.receipt_long},
        {'key': TabKey.profile, 'label': 'Profile', 'icon': Icons.person_outline, 'activeIcon': Icons.person},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _getNavItems();
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 30),
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10), // Efek shadow presisi ke bawah
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.map((item) {
          final TabKey key = item['key'];
          final String label = item['label'];
          final bool isActive = activeTab == key;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTabPress(key),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? item['activeIcon'] : item['icon'],
                    color: isActive ? AppColors.orange : AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? AppColors.orange : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}