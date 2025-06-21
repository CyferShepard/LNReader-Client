import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/chapter_list_item_tile.dart';
import 'package:light_novel_reader_client/components/expandable.dart';
import 'package:light_novel_reader_client/components/genre_chip.dart';
import 'package:light_novel_reader_client/components/label_text.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/reader.dart';

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
            apiController.clearDetails();
            historyController.clearNovelHistory();
          });
        }
      },
      child: Obx(
        () => Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            actions: [
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
                      color:
                          favouritesController.favourites.any((fav) => fav.url == apiController.details?.url) ? Colors.red : null,
                    ),
                    onPressed: () {
                      if (apiController.details?.url != null) {
                        favouritesController.addToFavourites(apiController.details!.url!, source ?? apiController.currentSource);
                      }
                    },
                  ),
                ),
              if (context.isTabletOrDesktop)
                Tooltip(
                  message: 'Refresh Details',
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      apiController.fetchDetails(apiController.details?.url ?? '',
                          source: source, refresh: true, canCacheChapters: canCacheChapters, canCacheNovel: canCacheNovel);
                    },
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await apiController.fetchDetails(apiController.details?.url ?? '',
                  source: source, refresh: true, canCacheChapters: canCacheChapters, canCacheNovel: canCacheNovel);
            },
            child: Obx(() {
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
          color: Colors.grey,
        ),
        height: 300,
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
        if (apiController.chapter != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50), // Full width button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
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
            child: Text(
              'Resume: ${apiController.chapter!.title} (${((historyController.novelhistory.firstWhereOrNull((historyItem) => historyItem.novel.url == apiController.details?.url && historyItem.chapter.url == apiController.chapter!.url && historyItem.source == source)?.position ?? 0) * 100).toStringAsFixed(2)}%)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
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
    return Padding(
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
            child: Center(
              child: Text(
                'Chapters: (${apiController.chapters?.length ?? 0})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
