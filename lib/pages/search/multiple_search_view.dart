import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/novel_card.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/search_result.dart';
import 'package:light_novel_reader_client/models/source_search.dart';
import 'package:light_novel_reader_client/pages/details/details_view.dart';

class MultipleSearchView extends StatefulWidget {
  const MultipleSearchView({super.key});

  @override
  State<MultipleSearchView> createState() => _MultipleSearchViewState();
}

class _MultipleSearchViewState extends State<MultipleSearchView> {
  final Map<int, ScrollController> _horizontalControllers = {};

  ScrollController _getOrCreateScrollController(int index) {
    return _horizontalControllers.putIfAbsent(index, () => ScrollController());
  }

  @override
  void dispose() {
    for (final controller in _horizontalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController(text: apiController.searchTerm);
    return Obx(
      () => PopScope(
        canPop: false,
        onPopInvokedWithResult: (popScope, result) {
          if (!uiController.isSubSearch) {
            apiController.clearSearch();
          }

          uiController.searchPage = 'sources'; // Reset to sources page
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: const Text('Global Search'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                apiController.clearSearch();
                uiController.searchPage = 'sources'; // Reset to sources page
              },
            ),
          ),
          body: apiController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CustomScrollView(
                  scrollDirection: Axis.vertical,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                              child: TextField(
                                controller: searchController,
                                onSubmitted: (value) async {
                                  String searchTerm = searchController.text.trim();
                                  apiController.searchTerm = searchTerm;
                                  await apiController.searchMultiple();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Search All Sources',
                                  hintText: 'Enter search term',
                                  border: OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () async {
                                      String searchTerm = searchController.text.trim();
                                      apiController.searchTerm = searchTerm;
                                      await apiController.searchMultiple();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          SourceSearch sourceSearch = apiController.multipleSourceSearch[index];
                          List<SearchResult> searchResults = sourceSearch.searchResult?.results ?? [];

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(sourceSearch.source,
                                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                            )),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_right_alt),
                                      tooltip: "More from ${sourceSearch.source}",
                                      onPressed: () async {
                                        uiController.searchPage = 'search';
                                        uiController.isSubSearch = true;
                                        apiController.currentSource = sourceSearch.source;
                                        await apiController.searchNovel();
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 340, // Set a fixed height for the horizontal list
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                    }),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      controller: _getOrCreateScrollController(index),
                                      itemCount: searchResults.length,
                                      itemBuilder: (context, idx) {
                                        final result = searchResults[idx];
                                        return NovelCard(
                                          novelCardData: NovelCardData(
                                            title: result.title,
                                            cover: result.cover,
                                            cacheImage: false,
                                            url: result.url,
                                            source: sourceSearch.source,
                                            chapterCount: result.chapterCount,
                                            genres: result.genres,
                                          ),
                                          onTap: () {
                                            apiController.fetchDetails(
                                              result.url,
                                              source: sourceSearch.source,
                                              canCacheChapters: false,
                                              canCacheNovel: false,
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DetailsView(
                                                  source: sourceSearch.source,
                                                  canCacheChapters: false,
                                                  canCacheNovel: false,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: apiController.multipleSourceSearch.length,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
