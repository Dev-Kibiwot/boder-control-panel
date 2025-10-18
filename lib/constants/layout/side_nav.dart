import 'package:boder/widgets/colors.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/spacing.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';

class SideNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback? onProfileTap;
  final bool isCollapsed;  
  const SideNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onProfileTap,
    this.isCollapsed = false,
  });
  static final List<NavItem> navItems = [
    const NavItem(
      index: 0,
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
    ),
    const NavItem(
      index: 1,
      icon: Icons.electric_bike_sharp,
      label: 'Riders',
    ),
    const NavItem(
      index: 2,
      icon: Icons.group,
      label: 'Users',
    ),
    const NavItem(
      index: 3,
      icon: Icons.train_sharp,
      label: 'Trips',
    ),
    const NavItem(
      index: 4,
      icon: Icons.attach_money_sharp,
      label: 'Wallets',
    ),
    const NavItem(
      index: 5,
      icon: Icons.security,
      label: 'Roles',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : verticalSpace(context, 0.25),
      height: verticalSpace(context, 1),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24),
            child: isCollapsed 
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business_center,
                    color: AppColors.white,
                    size: 24,
                  ),
                )
              : Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(
                              "assets/icons/logo.png"
                            )
                          )
                        ),
                      ),
                      if (!isCollapsed) ...[
                        CustomSpacing(width: 0.02),
                        CustomText(
                          "BODER",
                          fontSize: 20,
                          textColor: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ],
                  ),
          ),          
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                return buildNavItem(
                  context,
                  item: item,
                  isSelected: selectedIndex == item.index,
                  onTap: () => onItemSelected(item.index),
                );
              },
            ),
          ),
          if (isCollapsed)
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.sidebarHover,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.lightBlue,
                child: Icon(
                  Icons.person,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildNavItem(
    BuildContext context, {
    required NavItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 16 : 16, 
            vertical: 12
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
              ? Border.all(
                color: AppColors.lightBlue
              ) : null,
          ),
          child: isCollapsed 
            ? Tooltip(
                message: item.label,
                child: Center(
                  child: Icon(
                    item.icon,
                    color: isSelected ? AppColors.lightBlue : AppColors.white,
                    size: 20,
                  ),
                ),
              )
            : Row(
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? AppColors.lightBlue : AppColors.white,
                      size: 20,
                    ),
                    CustomSpacing(width: 0.025),
                    CustomText(
                      item.label,
                      fontSize: 14,
                      textColor: isSelected ? AppColors.lightBlue : AppColors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class NavItem {
  final int index;
  final IconData icon;
  final String label;
  
  const NavItem({
    required this.index,
    required this.icon,
    required this.label,
  });
}