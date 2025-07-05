import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/search/latest_view.dart';
import 'package:light_novel_reader_client/pages/search/search_view.dart';
import 'package:tab_container/tab_container.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController latestScrollController = ScrollController();
    final ScrollController searchScrollController = ScrollController();
    return Scaffold(
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
          },
        ),
      ),
      body: TabContainer(
        // controller: _tabController,
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
          Theme.of(context).colorScheme.secondary,
          Theme.of(context).colorScheme.secondary,
        ],
        tabs: [
          Text(
            'Latest',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
          ),
          Text(
            'Search',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
          ),
        ],
        children: [
          LatestView(scrollController: latestScrollController),
          SearchView(scrollController: searchScrollController),
        ],
      ),
    );
  }
}
