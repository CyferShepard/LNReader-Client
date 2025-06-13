import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/novel_card.dart';
import 'package:light_novel_reader_client/components/search_bar.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/details/details_view.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History (${historyController.history.length})'),
        actions: [
          CustomSearchBar(
            initialValue: historyController.searchQuery,
            onChanged: (value) {
              historyController.searchQuery = (value);
            },
            onClear: () {
              historyController.searchQuery = '';
            },
            hintText: 'Search History',
          ),
        ],
      ),
      body: Obx(() {
        if (historyController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (historyController.history.isEmpty) {
          return const Center(child: Text('No history found.'));
        }

        final items = historyController.history.where((historyItem) {
          final searchQuery = historyController.searchQuery.toLowerCase();
          return historyItem.novel.title.toLowerCase().contains(searchQuery);
        }).toList();

        if (items.isEmpty) {
          return const Center(
            child: Text('No history found'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200, // Each item's max width
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 200 / 410, // width / height
            ),
            itemBuilder: (context, index) {
              return NovelCard(
                novelCardData: NovelCardData(
                  title: items[index].novel.title,
                  cover: items[index].novel.cover,
                  url: items[index].novel.url,
                  source: items[index].source,
                ),
                novelCardChapterData: NovelCardChapterData(
                  date: items[index].lastRead,
                  index: items[index].chapter.index,
                ),
                onTap: () {
                  apiController.fetchDetails(
                    items[index].novel.url,
                    source: items[index].source,
                    lastChapterUrl: items[index].chapter.url,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsView(
                        source: items[index].source,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await historyController.getHistory();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
