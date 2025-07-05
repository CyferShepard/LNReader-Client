import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/filter_builder.dart';
import 'package:light_novel_reader_client/components/novel_card.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/source.dart';
import 'package:light_novel_reader_client/pages/details/details_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _setupScrollListener() {
    widget.scrollController.addListener(() async {
      if (widget.scrollController.position.pixels >= widget.scrollController.position.maxScrollExtent - 200) {
        final search = apiController.search;
        if (search != null && search.lastPage != null && search.currentPage! < search.lastPage! && !apiController.isLoading) {
          await apiController.searchNovel(
            page: search.currentPage! + 1,
          );
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _setupScrollListener(); // Ensure the listener is set up
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    apiController.clearSearch();
    print('SearchView disposed');

    super.dispose();
  }

  Future<void> beginSearch(String searchTerm) async {
    //  final searchTerm = searchController.text.trim();
    apiController.searchTerm = searchTerm;
    await apiController.searchNovel();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final search = apiController.search;
      if (widget.scrollController.hasClients &&
          widget.scrollController.position.maxScrollExtent == 0 &&
          search != null &&
          search.lastPage != null &&
          search.currentPage! < search.lastPage! &&
          !apiController.isLoading) {
        print('Fetching search results for page ${search.currentPage! + 1}');
        await apiController.searchNovel(
          page: search.currentPage! + 1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final TextEditingController searchController = TextEditingController(text: apiController.searchTerm);
    Source? source = apiController.sources.firstWhereOrNull((s) => s.name == apiController.currentSource);
    return Obx(
      () => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (value) async {
                      await beginSearch(searchController.text.trim());
                    },
                    decoration: InputDecoration(
                      labelText: 'Search ${apiController.currentSource}',
                      hintText: 'Enter search term',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          await beginSearch(searchController.text.trim());
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (source != null && source.hasFilters)
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => FilterBuilder(
                        filters: source.filters,
                        onApply: (value) {
                          apiController.filters = value;
                          print(value);
                          apiController.searchNovel();
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
          Expanded(
            child: Obx(() {
              if (apiController.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (apiController.searchResults.isEmpty) {
                return const Center(
                  child: Text('No results found.'),
                );
              }

              final items = apiController.searchResults;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: items.length,
                  controller: widget.scrollController,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200, // Each item's max width
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    childAspectRatio: 200 / 350, // width / height
                  ),
                  itemBuilder: (context, index) {
                    return NovelCard(
                      maxHeight: 350,
                      novelCardData: NovelCardData(
                        title: items[index].title,
                        cover: items[index].cover,
                        cacheImage: false,
                        url: items[index].url,
                        source: apiController.currentSource,
                        chapterCount: items[index].chapterCount,
                        genres: items[index].genres,
                      ),
                      onTap: () {
                        apiController.fetchDetails(
                          items[index].url,
                          canCacheChapters: false,
                          canCacheNovel: false,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsView(
                              canCacheChapters: false,
                              canCacheNovel: false,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
