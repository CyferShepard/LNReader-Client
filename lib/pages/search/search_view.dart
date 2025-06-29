import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/novel_card.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/details/details_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Future<void> beginSearch(String searchTerm) async {
    //  final searchTerm = searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      await apiController.search(searchTerm);
    } else {
      print('Error: Please enter a search term.');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final TextEditingController searchController = TextEditingController();
    return Obx(
      () => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
