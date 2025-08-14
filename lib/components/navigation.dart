import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/components/nav_bar.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';

class MainNavigationBar extends StatefulWidget {
  const MainNavigationBar({super.key, required this.navItems, this.bottomNavItems});

  final List<NavBarItem> navItems;
  final List<NavBarItem>? bottomNavItems;

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
    return PopScope(
      canPop: pageController.hasClients && pageController.page == 0, // Disable pop if not on the first page
      onPopInvokedWithResult: (didPop, result) {
        print('Pop invoked with canPop: $didPop, result: $result, index: ${pageController.page}');
        if (uiController.searchPage == "sources" && uiController.settingsPage == "main") {
          try {
            pageController.jumpToPage(0);
            navController.select(0); // Reset the selected index
          } catch (e) {
            print('Error resetting page controller: $e');
          }
        }
      },
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(), // <-- Disable swipe

              onPageChanged: (index) {
                navController.select(index);
                setState(() {});
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
                  indicatorColor: Theme.of(context).colorScheme.surface,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDesktopNavigationBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SideNavBar(
          items: widget.navItems,
          bottomItems: widget.bottomNavItems,
          controller: navController,
          style: SideNavBarStyle(
            backgroundColor: Theme.of(context).colorScheme.primary,
            selectedItemStyle: SelectedItemStyle(
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(220),
                fontWeight: FontWeight.bold,
              ),
              iconColor: Theme.of(context).colorScheme.onSurface.withAlpha(220),
            ),
            unselectedIconColor: Theme.of(context).colorScheme.onPrimary,
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
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
