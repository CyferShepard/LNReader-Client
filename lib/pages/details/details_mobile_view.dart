import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/categories_dropdown.dart';
import 'package:light_novel_reader_client/components/chapter_list_item_tile.dart';
import 'package:light_novel_reader_client/components/expandable.dart';
import 'package:light_novel_reader_client/components/genre_chip.dart';
import 'package:light_novel_reader_client/components/label_text.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/reader.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsMobilePage extends StatelessWidget {
  final String? source;
  final bool canCacheChapters;
  final bool canCacheNovel;

  const DetailsMobilePage({super.key, this.source, this.canCacheChapters = true, this.canCacheNovel = true});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          print('Details page popped');
          Future.delayed(Duration(milliseconds: 100), () {
            if (apiController.details?.url != null) {
              int readCount = historyController.novelhistory.length;
              favouritesController.updateReadCount(
                  readCount, apiController.details?.url ?? '', source ?? apiController.currentSource);
            }
            apiController.clearDetails();
            historyController.clearNovelHistory();
          });
        }
      },
      child: Obx(
        () => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            actions: [
              if (apiController.details != null && favouritesController.favourites.isNotEmpty)
                IconButton(
                  icon: Icon(
                    favouritesController.favourites.any((fav) => fav.url == apiController.details?.url)
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    color:
                        favouritesController.favourites.any((fav) => fav.url == apiController.details?.url) ? Colors.red : null,
                  ),
                  tooltip: favouritesController.favourites.any((fav) => fav.url == apiController.details?.url)
                      ? 'Remove from Favourites'
                      : 'Add to Favourites',
                  onPressed: () {
                    if (apiController.details?.url != null) {
                      favouritesController.addToFavourites(apiController.details!.url!, source ?? apiController.currentSource);
                    }
                  },
                ),
              if (favouritesController.favourites.any((fav) => fav.url == apiController.details?.url) &&
                  uiController.categories.isNotEmpty &&
                  uiController.categories[0].position != -999)
                CategoriesDropdownButton(
                  onChanged: (p0) {
                    apiController.setCategories(p0, novelDetails: apiController.details);
                  },
                ),
              if ((apiController.details != null && apiController.details!.fullUrl != null) ||
                  (apiController.chapter != null && apiController.chapter!.fullUrl != null))
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Open in Browser',
                  onPressed: () async {
                    final url = apiController.details?.fullUrl;
                    if (url != null) {
                      try {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } catch (e) {
                        // Optionally show an error to the user
                        print('Could not launch $url: $e');
                      }
                    }
                  },
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await apiController.fetchDetails(
                apiController.details?.url ?? '',
                source: source,
                refresh: true,
                canCacheChapters: canCacheChapters,
                canCacheNovel: canCacheNovel,
              );
            },
            child: Obx(() {
              if (apiController.isLoading) {
                return Center(child: context.isTabletOrDesktop ? CircularProgressIndicator() : Container());
              }

              if (apiController.details == null) {
                return const Center(
                  child: Text('No details available.'),
                );
              }

              return detailsView(context);
            }),
          ),
        ),
      ),
    );
  }

  List<Widget> metaDetails(BuildContext context) {
    // Placeholder for the image in case cover is not available
    {
      Widget placeHolderImage = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Adjust the radius as needed
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        height: 200,
        width: 150,
        child: const Icon(
          Icons.image,
          size: 50,
        ),
      );
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            apiController.details!.cover != null && apiController.details!.cover != ""
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12), // Adjust the radius as needed
                    child: Image.network(
                      '${client.baseUrl}/proxy/imageProxy?imageUrl=${apiController.details!.cover!}',
                      // width: 100,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => placeHolderImage,
                    ),
                  )
                : placeHolderImage,

            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apiController.details!.title,
                    softWrap: true,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  if (apiController.details?.source != null) const SizedBox(height: 8),
                  if (apiController.details?.source != null)
                    LabeledText(
                      label: 'Source',
                      text: apiController.details!.source!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  const SizedBox(height: 8),
                  LabeledText(
                    label: 'Author',
                    text: apiController.details!.author,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  LabeledText(
                      label: 'Status',
                      text: apiController.details!.status,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                  const SizedBox(height: 8),
                  LabeledText(
                    label: 'Genre',
                    softWrap: true,
                    maxLines: 5,
                    text: apiController.details!.genre.join(', '),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  LabeledText(
                    label: 'Last Updated',
                    text: apiController.details!.lastUpdate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (apiController.details?.lastHistory != null) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              // minimumSize: const Size(double.infinity, 50), // Full width button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReaderPage(
                    source: source,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: Text(
                'Chapter ${apiController.details?.lastHistory!.chapter.index} (${((apiController.details?.lastHistory?.position ?? 0) * 100).toStringAsFixed(2)}%)'),
          ),
        ],
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (apiController.details!.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final tags in apiController.details!.tags)
                    GenreChip(
                      genre: tags.trim(),
                      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
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
            ExpandableText(
              text: apiController.details!.summary,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ];
    }
  }

  Widget detailsView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: metaDetails(context),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Chapters: (${apiController.chapters?.length ?? 0})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort_by_alpha),
                    tooltip: 'Sort Chapters',
                    onPressed: () {
                      apiController.sortAsc = !apiController.sortAsc; // Toggle sort direction
                      apiController.chapters = List.from(apiController.chapters ?? [])
                        ..sort((a, b) => apiController.sortAsc ? a.index.compareTo(b.index) : b.index.compareTo(a.index));
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 8)),
          if (apiController.isChaptersLoading) SliverToBoxAdapter(child: const Center(child: CircularProgressIndicator())),
          if (!apiController.isChaptersLoading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Obx(
                    () => ChapterListItemTile(
                      title: apiController.chapters![index].title,
                      position: historyController.novelhistory
                          .firstWhereOrNull((historyItem) =>
                              historyItem.novel.url == apiController.details?.url &&
                              historyItem.chapter.url == apiController.chapters![index].url &&
                              historyItem.source == source)
                          ?.position,
                      selected: apiController.chapters![index].url == apiController.chapter?.url,
                      onTap: () {
                        apiController.fetchChapter(apiController.chapters![index].url, source: source);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReaderPage(source: source),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: apiController.chapters?.length ?? 0,
              ),
            ),
        ],
      ),
    );
  }
}
