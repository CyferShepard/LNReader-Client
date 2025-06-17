import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/chapter_list_item_tile.dart';
import 'package:light_novel_reader_client/components/font_settings.dart';
import 'package:light_novel_reader_client/components/genre_chip.dart';
import 'package:light_novel_reader_client/components/label_text.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/reader.dart';

class DetailsDesktopPage extends StatelessWidget {
  final String? source;
  final bool canCacheChapters;
  final bool canCacheNovel;

  const DetailsDesktopPage({super.key, this.source, required this.canCacheChapters, required this.canCacheNovel});

  @override
  Widget build(BuildContext context) {
    // Fetch details when the page is opened
    // apiController.fetchDetails(novelUrl);
    final focusNode = FocusNode();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Handle the pop action, e.g., navigate back or refresh
          print('Details page popped');

          Future.delayed(Duration(milliseconds: 100), () => apiController.clearDetails());
        }
      },
      child: Focus(
        autofocus: true,
        focusNode: focusNode,
        onKeyEvent: (node, event) {
          // Example: Left arrow for previous, right arrow for next
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (apiController.chapter?.previousPage != null && apiController.chapter!.previousPage!.isNotEmpty) {
              apiController.fetchChapter(apiController.chapter!.previousPage!, source: source);
              return KeyEventResult.handled;
            }
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (apiController.chapter?.nextPage != null && apiController.chapter!.nextPage!.isNotEmpty) {
              apiController.fetchChapter(apiController.chapter!.nextPage!, source: source);
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
                if (apiController.chapter?.previousPage != null && apiController.chapter!.previousPage!.isNotEmpty)
                  Tooltip(
                    message: 'Previous Chapter',
                    child: IconButton(
                      icon: const Icon(Icons.navigate_before),
                      onPressed: () {
                        apiController.fetchChapter(apiController.chapter!.previousPage!, source: source);
                      },
                    ),
                  ),
                if (apiController.chapter?.nextPage != null && apiController.chapter!.nextPage!.isNotEmpty)
                  Tooltip(
                    message: 'Next Chapter',
                    child: IconButton(
                      icon: const Icon(Icons.navigate_next),
                      onPressed: () {
                        apiController.fetchChapter(apiController.chapter!.nextPage!, source: source);
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
                              apiController.details!.url!, source ?? apiController.currentSource);
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
                            source: source, refresh: true, canCacheChapters: canCacheChapters, canCacheNovel: canCacheNovel);
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

              // double detailsWidth = MediaQuery.of(context).size.width * 0.3; // Set a width for the details section
              // print(detailsWidth);
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 350),
                    child: SingleChildScrollView(
                      child: detailsView(context),
                    ),
                  ),
                  Expanded(
                    child: ReaderPage(
                      showHeader: false,
                      source: source,
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
      height: 300,
      child: const Icon(
        Icons.image,
        size: 50,
      ),
    );
    return Container(
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
                    height: 450,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => placeHolderImage,
                  ),
                )
              : placeHolderImage,
          const SizedBox(height: 16),
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
                    // margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
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
          const SizedBox(height: 8),
          Text(
            apiController.details!.summary,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 24),
          Text(
            'Chapters: (${apiController.chapters?.length ?? 0})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(height: 8),
          if (apiController.isChaptersLoading) const Center(child: CircularProgressIndicator()),
          if (!apiController.isChaptersLoading)
            Obx(
              () => chaptersList(),
            ),
        ],
      ),
    );
  }

  Widget chaptersList() {
    if (apiController.chapters == null || apiController.chapters!.isEmpty) {
      return Expanded(
        child: const Center(
          child: Text('No chapters available.'),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: apiController.chapters!.length,
      itemBuilder: (context, index) {
        // final chapter = apiController.chapters![index];
        // print('${apiController.chapters![index].url}, ${apiController.chapter?.url}');
        return Obx(
          () => ChapterListItemTile(
            title: apiController.chapters![index].title,
            selected: apiController.chapters![index].url == apiController.chapter?.url,
            onTap: () {
              apiController.fetchChapter(apiController.chapters![index].url, source: source);
            },
          ),
        );
      },
    );
  }
}
