import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/search/latest_view.dart';
import 'package:light_novel_reader_client/pages/search/search_view.dart';
import 'package:tab_container/tab_container.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (uiController.isSubSearch) {
        // _tabController.index = 1; // Switch to Search tab if it's a sub-search
        _tabController.animateTo(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController latestScrollController = ScrollController();
    final ScrollController searchScrollController = ScrollController();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (popScope, result) {
        try {
          latestScrollController.jumpTo(0); // Reset scroll position to top
        } catch (e) {
          print('Error resetting latest scroll position: $e');
        }
        try {
          searchScrollController.jumpTo(0); // Reset scroll position to top
        } catch (e) {
          print('Error resetting search scroll position: $e');
        }
        apiController.currentSource = '';
        uiController.searchPage = uiController.isSubSearch ? 'globalSearch' : 'sources'; // Reset to sources page
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              try {
                latestScrollController.jumpTo(0); // Reset scroll position to top
              } catch (e) {
                print('Error resetting latest scroll position: $e');
              }
              try {
                searchScrollController.jumpTo(0); // Reset scroll position to top
              } catch (e) {
                print('Error resetting search scroll position: $e');
              }
              // uiController.selectedIndex = 2; // Navigate back to the previous page
              apiController.currentSource = '';
              uiController.searchPage = uiController.isSubSearch ? 'globalSearch' : 'sources'; // Reset to sources page
            },
          ),
        ),
        body: TabContainer(
          controller: _tabController,
          key: const Key('search_tab_container'),
          tabEdge: TabEdge.top,
          borderRadius: BorderRadius.circular(10),
          tabBorderRadius: BorderRadius.circular(10),
          // childPadding: const EdgeInsets.only(top: 8),
          selectedTextStyle: const TextStyle(
            fontSize: 15.0,
          ),
          unselectedTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 13.0,
          ),
          colors: [
            Theme.of(context).colorScheme.tertiary,
            Theme.of(context).colorScheme.tertiary,
          ],
          tabs: [
            Text(
              'Latest',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            Text(
              'Search',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
          children: [
            LatestView(scrollController: latestScrollController),
            SearchView(scrollController: searchScrollController),
          ],
        ),
      ),
    );
  }
}
