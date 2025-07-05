import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/components/nav_bar.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';

class MainNavigationBar extends StatefulWidget {
  const MainNavigationBar({super.key, required this.navItems});

  final List<NavBarItem> navItems;

  @override
  State<MainNavigationBar> createState() => _MainNavigationBarState();
}

class _MainNavigationBarState extends State<MainNavigationBar> {
  final PageController pageController = PageController();
  SideNavBarController get navController => uiController.navController;

  @override
  void initState() {
    navController.addListener(() {
      if (pageController.positions.isNotEmpty) {
        pageController.jumpToPage(navController.selectedIndex);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return context.isTabletOrDesktop ? buildDesktopNavigationBar(context) : buildMobileNavigationBar(context);
  }

  Widget buildMobileNavigationBar(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: pageController,
            onPageChanged: (index) {
              navController.select(index);
            },
            children: widget.navItems.where((item) => item.showInMobile).map((item) => item.child).toList(),
          ),
        ),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: AnimatedBuilder(
            animation: navController,
            builder: (context, _) {
              final navItems = widget.navItems.where((item) => item.showInMobile).toList();
              final destinations = navItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                      selectedIcon: Icon(
                        item.icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                  .toList();

              // Check and reset selectedIndex if out of bounds
              if (navController.selectedIndex >= destinations.length) {
                navController.select(0);
              }

              return NavigationBar(
                selectedIndex: navController.selectedIndex,
                onDestinationSelected: (index) {
                  var item = navItems[index];
                  if (item.onTap != null) {
                    item.onTap!();
                    if (item.navigateWithOnTap) {
                      navController.select(index);
                    }
                  } else {
                    navController.select(index);
                  }
                },
                destinations: destinations,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildDesktopNavigationBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SideNavBar(
          items: widget.navItems,
          controller: navController,
          style: SideNavBarStyle(
            backgroundColor: Theme.of(context).colorScheme.primaryFixed,
            selectedItemStyle: SelectedItemStyle(
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              iconColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: pageController,
            onPageChanged: (index) {
              navController.select(index);
            },
            children: widget.navItems.map((item) => item.child).toList(),
          ),
        ),
      ],
    );
  }
}
