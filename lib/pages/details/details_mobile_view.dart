import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/chapter_list_item_tile.dart';
import 'package:light_novel_reader_client/components/expandable.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/reader.dart';

class DetailsMobilePage extends StatelessWidget {
  final String? source;

  const DetailsMobilePage({super.key, this.source});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          print('Details page popped');
          Future.delayed(Duration(milliseconds: 100), () => apiController.clearDetails());
        }
      },
      child: Obx(
        () => Scaffold(
          appBar: AppBar(
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
                      apiController.fetchDetails(apiController.details?.url ?? '', source: source);
                    },
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await apiController.fetchDetails(apiController.details?.url ?? '', source: source);
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  child: Text(
                    apiController.details!.title,
                    softWrap: true,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (apiController.details!.genre.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final tag in apiController.details!.genre)
                        Chip(
                          label: Text(tag),
                          labelStyle: Theme.of(context).textTheme.bodyMedium,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary,
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
            const SizedBox(height: 16),
            Text(
              'Chapters: (${apiController.chapters?.length ?? 0})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (apiController.isChaptersLoading) const Center(child: CircularProgressIndicator()),
            if (!apiController.isChaptersLoading)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () {
                    if (apiController.chapters == null || apiController.chapters!.isEmpty) {
                      return const Center(
                        child: Text('No chapters available.'),
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
                              print('Chapter Selected: You selected ${apiController.chapters![index].title}');
                              apiController.fetchChapter(apiController.chapters![index].url, source: source);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReaderPage(
                                    source: source,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
