import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/novel_card.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/details/details_view.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

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
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // uiController.selectedIndex = 2; // Navigate back to the previous page
            apiController.currentSource = '';
          },
        ),
      ),
      body: Column(
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

              // List<NovelCard> itemsCards = items.map((item) {
              //   return NovelCard(
              //     maxHeight: 350,
              //     novelCardData: NovelCardData(
              //       title: item.title,
              //       cover: item.cover,
              //       url: item.url,
              //       source: apiController.currentSource,
              //       genres: item.genres,
              //     ),
              //     onTap: () {
              //       apiController.fetchDetails(
              //         item.url,
              //         canCacheChapters: false,
              //       );
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => DetailsView(
              //             canCacheChapters: false,
              //           ),
              //         ),
              //       );
              //     },
              //   );
              // }).toList();

              // return Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: ItemCardLayoutGrid(
              //     items: itemsCards,
              //     itemHeight: 350,
              //     itemWidth: 200,
              //     horizontalGap: 2,
              //     verticalGap: 2,
              //   ),
              // );

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
                        url: items[index].url,
                        source: apiController.currentSource,
                        chapterCount: items[index].chapterCount,
                        genres: items[index].genres,
                      ),
                      onTap: () {
                        apiController.fetchDetails(
                          items[index].url,
                          canCacheChapters: false,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsView(
                              canCacheChapters: false,
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

  // ListTile searchResult(SearchResult result, BuildContext context) {
  //   return ListTile(
  //     title: Text(result.title),
  //     subtitle: Text(result.summary),
  //     leading: result.cover.isNotEmpty ? Image.network(result.cover, height: 50, fit: BoxFit.cover) : const Icon(Icons.book),
  //     onTap: () {
  //       // print('Selected', 'You selected ${result.title}');
  //       apiController.fetchDetails(result.url);
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => DetailsView(),
  //         ),
  //       );
  //       // Handle navigation or further actions here
  //     },
  //   );
  // }
}
