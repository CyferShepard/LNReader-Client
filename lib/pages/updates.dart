import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:light_novel_reader_client/components/default_placeholder_image.dart';
import 'package:light_novel_reader_client/components/search_bar.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/details/details_view.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: Text('Updates (${historyController.history.length})'),
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
            if (context.isTabletOrDesktop)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await historyController.getHistory();
                },
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await historyController.getHistory();
          },
          child: Obx(() {
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

            // --- Group items by date ---
            final Map<String, List<dynamic>> grouped = {};
            final dateFormat = DateFormat('yyyy-MM-dd');
            for (var item in items) {
              final dateKey = dateFormat.format(item.lastRead); // assuming lastRead is DateTime
              grouped.putIfAbsent(dateKey, () => []).add(item);
            }
            final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a)); // newest first

            // --- Build a flat list with headers and items ---
            final List<Map<String, dynamic>> displayList = [];
            for (final key in sortedKeys) {
              displayList.add({'isHeader': true, 'date': key});
              for (final item in grouped[key]!) {
                displayList.add({'isHeader': false, 'item': item});
              }
            }

            const placeHolderImage = DefaultPlaceholderImage();

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final entry = displayList[index];
                  if (entry['isHeader'] == true) {
                    // Date header
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        DateFormat.yMMMMd().format(DateTime.parse(entry['date'])),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    );
                  } else {
                    final historyItem = entry['item'];
                    final novelCardData = historyItem.novel;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          apiController.fetchDetails(
                            historyItem.novel.url,
                            source: historyItem.source,
                            lastChapterUrl: historyItem.chapter.url,
                            canCacheChapters: true,
                            canCacheNovel: true,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsView(
                                source: historyItem.source,
                                canCacheChapters: true,
                                canCacheNovel: true,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                height: 100,
                                width: 70,
                                '${client.baseUrl}/proxy/imageProxy?imageUrl=${novelCardData.cover}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => placeHolderImage,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(novelCardData.title),
                                  Text(
                                    'Chapter ${historyItem.chapter.index} - ${DateFormat.jm().format(historyItem.lastRead)} - ${((historyItem.position ?? 0) * 100).toStringAsFixed(2)}%',
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  historyController.removeFromHistory(historyItem.chapter.url, historyItem.source);
                                },
                                icon: Icon(Icons.delete)),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
