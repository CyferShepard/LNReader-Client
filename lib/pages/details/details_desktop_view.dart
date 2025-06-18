import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/chapter_list_item_tile.dart';
import 'package:light_novel_reader_client/components/font_settings.dart';
import 'package:light_novel_reader_client/components/genre_chip.dart';
import 'package:light_novel_reader_client/components/label_text.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/reader.dart';
import 'package:tab_container/tab_container.dart';

class DetailsDesktopPage extends StatefulWidget {
  final String? source;
  final bool canCacheChapters;
  final bool canCacheNovel;

  const DetailsDesktopPage({super.key, this.source, required this.canCacheChapters, required this.canCacheNovel});

  @override
  State<DetailsDesktopPage> createState() => _DetailsDesktopPageState();
}

class _DetailsDesktopPageState extends State<DetailsDesktopPage> {
  bool showChapters = false;

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          print('Details page popped');

          Future.delayed(Duration(milliseconds: 100), () {
            apiController.clearDetails();
            historyController.clearNovelHistory();
            uiController.clearChapterSelection();
          });
        }
      },
      child: Focus(
        autofocus: true,
        focusNode: focusNode,
        onKeyEvent: (node, event) {
          // Example: Left arrow for previous, right arrow for next
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (apiController.chapter?.previousPage != null && apiController.chapter!.previousPage!.isNotEmpty) {
              apiController.fetchChapter(apiController.chapter!.previousPage!, source: widget.source);
              return KeyEventResult.handled;
            }
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (apiController.chapter?.nextPage != null && apiController.chapter!.nextPage!.isNotEmpty) {
              apiController.fetchChapter(apiController.chapter!.nextPage!, source: widget.source);
              return KeyEventResult.handled;
            }
          }

          return KeyEventResult.ignored;
        },
        child: Obx(
          () => Scaffold(
            appBar: AppBar(
              title: Text(apiController.details?.title != null
                  ? (apiController.chapter?.title != null ? apiController.chapter!.title : apiController.details!.title)
                  : 'Novel Details'),
              actions: [
                if (uiController.multiSelectMode)
                  Row(
                    children: [
                      if (historyController.novelhistory.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.check_circle),
                          tooltip: 'Mark as Read',
                          onPressed: () {
                            historyController.markAsRead(
                                apiController.chapters!
                                    .where((c) => uiController.selectedChapters.contains(c.index - 1))
                                    .toList(),
                                apiController.details!,
                                widget.source ?? apiController.currentSource);
                            Get.toNamed('/history');
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.select_all),
                        tooltip: 'Select All',
                        onPressed: () => uiController.selectAllChapters(apiController.chapters!.length),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear Selection',
                        onPressed: uiController.clearChapterSelection,
                      ),
                      // ...other actions
                    ],
                  ),
                if (apiController.chapter?.previousPage != null && apiController.chapter!.previousPage!.isNotEmpty)
                  Tooltip(
                    message: 'Previous Chapter',
                    child: IconButton(
                      icon: const Icon(Icons.navigate_before),
                      onPressed: () {
                        apiController.fetchChapter(apiController.chapter!.previousPage!, source: widget.source);
                      },
                    ),
                  ),
                if (apiController.chapter?.nextPage != null && apiController.chapter!.nextPage!.isNotEmpty)
                  Tooltip(
                    message: 'Next Chapter',
                    child: IconButton(
                      icon: const Icon(Icons.navigate_next),
                      onPressed: () {
                        apiController.fetchChapter(apiController.chapter!.nextPage!, source: widget.source);
                      },
                    ),
                  ),
                if (apiController.details != null && favouritesController.favourites.isNotEmpty)
                  Tooltip(
                    message: favouritesController.favourites.any((fav) => fav.url == apiController.details?.url)
                        ? 'Remove from Favourites'
                        : 'Add to Favourites',
                    child: IconButton(
                      icon: Icon(
                        favouritesController.favourites.any((fav) => fav.url == apiController.details?.url)
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: favouritesController.favourites.any((fav) => fav.url == apiController.details?.url)
                            ? Colors.red
                            : null,
                      ),
                      onPressed: () {
                        if (apiController.details?.url != null) {
                          favouritesController.addToFavourites(
                              apiController.details!.url!, widget.source ?? apiController.currentSource);
                        }
                      },
                    ),
                  ),
                FontSettingsButton(),
                if (apiController.details != null && apiController.details!.url != null)
                  Tooltip(
                    message: 'Refresh Details',
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        apiController.fetchDetails(apiController.details!.url!,
                            source: widget.source,
                            refresh: true,
                            canCacheChapters: widget.canCacheChapters,
                            canCacheNovel: widget.canCacheNovel);
                      },
                    ),
                  ),
              ],
            ),
            body: Obx(() {
              if (apiController.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (apiController.details == null) {
                return const Center(
                  child: Text('No details available.'),
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 350),
                    child: TabContainer(
                      tabEdge: TabEdge.top,
                      borderRadius: BorderRadius.circular(10),
                      tabBorderRadius: BorderRadius.circular(10),
                      childPadding: const EdgeInsets.only(top: 8),
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
                          'Details',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                        ),
                        Text(
                          'Chapters (${apiController.chapters?.length ?? 0})',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                        ),
                      ],
                      children: [
                        detailsView(context),
                        chaptersList(context),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ReaderPage(
                      showHeader: false,
                      source: widget.source,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget detailsView(BuildContext context) {
    Widget placeHolderImage = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Adjust the radius as needed
        color: Colors.grey,
      ),
      height: 310,
      child: const Icon(
        Icons.image,
        size: 50,
      ),
    );
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            apiController.details!.cover != null && apiController.details!.cover != ""
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12), // Adjust the radius as needed
                    child: Image.network(
                      '${client.baseUrl}/proxy/imageProxy?imageUrl=${apiController.details!.cover!}',
                      // height: 350,
                      width: 310,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => placeHolderImage,
                    ),
                  )
                : placeHolderImage,
            const SizedBox(height: 8),
            metaDetails(context),
            const SizedBox(height: 8),
            if (apiController.details!.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final genre in apiController.details!.tags)
                    GenreChip(
                      genre: genre.trim(),
                      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              child: Text(
                apiController.details!.summary,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget metaDetails(BuildContext context) {
    return SizedBox(
      width: 320,
      // height: 350,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary.withAlpha(102),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              apiController.details!.title,
              softWrap: true,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            LabeledText(
              label: 'Author',
              text: apiController.details!.author,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
            ),
            const SizedBox(height: 8),
            LabeledText(
              label: 'Status',
              text: ' ${apiController.details!.status}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
            ),
            const SizedBox(height: 8),
            LabeledText(
              label: 'Genre',
              text: apiController.details!.genre.join(', '),
              softWrap: true,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
            ),
            const SizedBox(height: 8),
            LabeledText(
              label: 'Last Updated',
              text: apiController.details!.lastUpdate,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chaptersList(BuildContext context) {
    if (apiController.chapters == null || apiController.chapters!.isEmpty) {
      return const Center(
        child: Text('No chapters available.'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: apiController.chapters?.length ?? 0,
        itemBuilder: (context, index) {
          return Obx(() {
            final chapter = apiController.chapters![index];
            final isSelected = uiController.selectedChapters.contains(index);
            final isCurrent = chapter.url == apiController.chapter?.url;
            final position = historyController.novelhistory
                .firstWhereOrNull((historyItem) =>
                    historyItem.novel.url == apiController.details?.url &&
                    historyItem.chapter.url == chapter.url &&
                    historyItem.source == widget.source)
                ?.position;

            return GestureDetector(
              key: ValueKey(index),
              onLongPress: () => uiController.toggleChapterSelection(index, apiController.chapters!.length),
              onTap: () {
                if (uiController.multiSelectMode) {
                  uiController.toggleChapterSelection(index, apiController.chapters!.length);
                } else {
                  apiController.fetchChapter(chapter.url, source: widget.source);
                }
              },
              child: Container(
                color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : null,
                child: ChapterListItemTile(
                  title: chapter.title,
                  position: position,
                  selected: isCurrent,
                  onTap:
                      uiController.multiSelectMode ? null : () => apiController.fetchChapter(chapter.url, source: widget.source),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
