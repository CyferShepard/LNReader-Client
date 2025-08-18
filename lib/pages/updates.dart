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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: Text('Updates (${updatesController.updates.length})'),
          actions: [
            CustomSearchBar(
              initialValue: updatesController.searchQuery,
              onChanged: (value) {
                updatesController.searchQuery = (value);
              },
              onClear: () {
                updatesController.searchQuery = '';
              },
              hintText: 'Search Latest',
            ),
            if (context.isTabletOrDesktop)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await updatesController.getUpdates();
                },
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await updatesController.getUpdates();
          },
          child: Obx(() {
            if (updatesController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (updatesController.updates.isEmpty) {
              return const Center(child: Text('No Chapters found.'));
            }

            final items = updatesController.updates.where((updateItem) {
              final searchQuery = updatesController.searchQuery.toLowerCase();
              return updateItem.title.toLowerCase().contains(searchQuery) ||
                  updateItem.chapter.title.toLowerCase().contains(searchQuery);
            }).toList();

            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: context.height / 1.25,
                    child: const Center(child: Text('No Chapters found.')),
                  ),
                ],
              );
            }

            // --- Group items by date ---
            final Map<String, List<dynamic>> grouped = {};
            final dateFormat = DateFormat('yyyy-MM-dd');
            for (var item in items) {
              final dateKey = dateFormat.format(item.chapter.dateAdded); // assuming lastRead is DateTime
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
              padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
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
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    );
                  } else {
                    final updateItem = entry['item'];
                    final novelCardData = updateItem;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 108,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            apiController.fetchDetails(
                              updateItem.url,
                              source: updateItem.source,
                              canCacheChapters: true,
                              canCacheNovel: true,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsView(
                                  source: updateItem.source,
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
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      novelCardData.title,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.isTabletOrDesktop
                                          ? Theme.of(context).textTheme.headlineSmall
                                          : Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      'Chapter ${updateItem.chapter.chapterIndex} - ${DateFormat.jm().format(updateItem.chapter.dateAdded)}',
                                      style: (context.isTabletOrDesktop
                                              ? Theme.of(context).textTheme.bodyLarge
                                              : Theme.of(context).textTheme.bodyMedium)
                                          ?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // IconButton(
                              //     onPressed: () {
                              //       historyController.removeFromHistory(historyItem.chapter.url, historyItem.source);
                              //     },
                              //     icon: Icon(Icons.delete)),
                            ],
                          ),
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
