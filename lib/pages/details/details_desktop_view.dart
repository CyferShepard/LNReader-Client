import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/categories_dropdown.dart';
import 'package:light_novel_reader_client/components/font_settings.dart';
import 'package:light_novel_reader_client/components/genre_chip.dart';
import 'package:light_novel_reader_client/components/label_text.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/details/chapter_list_view.dart';
import 'package:light_novel_reader_client/pages/reader.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tab_container/tab_container.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsDesktopPage extends StatefulWidget {
  final String? source;
  final bool canCacheChapters;
  final bool canCacheNovel;

  const DetailsDesktopPage({super.key, this.source, required this.canCacheChapters, required this.canCacheNovel});

  @override
  State<DetailsDesktopPage> createState() => _DetailsDesktopPageState();
}

class _DetailsDesktopPageState extends State<DetailsDesktopPage> with TickerProviderStateMixin {
  bool showChapters = false;
  late final ItemScrollController _chaptersScrollController;
  late TabController _tabController;

  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _chaptersScrollController = ItemScrollController();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!mounted) return;
      if (_tabController.index == 1 && _tabController.indexIsChanging == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) scrollToSelectedChapter();
        });
      }
    });
  }

  void scrollToSelectedChapter() async {
    if (loaded) return; // <-- Add this line to prevent multiple calls
    final selectedIndex = apiController.chapters?.indexWhere(
      (c) => c.url == apiController.chapter?.url,
    );
    if (selectedIndex == null || selectedIndex < 0) return;

    if (_chaptersScrollController.isAttached) {
      _chaptersScrollController.jumpTo(
        index: selectedIndex,
      );
      setState(() {
        loaded = true; // <-- Set loaded to true after scrolling
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          print('Details page popped');

          Future.delayed(Duration(milliseconds: 100), () {
            if (apiController.details?.url != null) {
              int readCount = historyController.novelhistory.length;
              favouritesController.updateReadCount(
                  readCount, apiController.details?.url ?? '', widget.source ?? apiController.currentSource);
            }
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
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            appBar: AppBar(
              scrolledUnderElevation: 0,
              title: Text(apiController.details?.title != null
                  ? (apiController.chapter?.title != null ? apiController.chapter!.title : apiController.details!.title)
                  : 'Novel Details'),
              actions: [
                if (uiController.multiSelectMode)
                  Row(
                    children: [
                      if (uiController.selectedChapters.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          tooltip: 'Mark as Unread',
                          onPressed: () {
                            historyController.markAsRead(
                              apiController.chapters!.where((c) => uiController.selectedChapters.contains(c.index - 1)).toList(),
                              apiController.details!,
                              widget.source ?? apiController.currentSource,
                              isRead: false,
                            );
                            Get.toNamed('/history');
                          },
                        ),
                      if (uiController.selectedChapters.isNotEmpty)
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
                  IconButton(
                    icon: const Icon(Icons.navigate_before),
                    tooltip: 'Previous Chapter',
                    onPressed: () {
                      apiController.fetchChapter(apiController.chapter!.previousPage!, source: widget.source);
                    },
                  ),
                if (apiController.chapter?.nextPage != null && apiController.chapter!.nextPage!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.navigate_next),
                    tooltip: 'Next Chapter',
                    onPressed: () {
                      apiController.fetchChapter(apiController.chapter!.nextPage!, source: widget.source);
                    },
                  ),
                if (apiController.details != null)
                  IconButton(
                    tooltip: favouritesController.favourites.any((fav) => fav.url == apiController.details?.url)
                        ? 'Remove from Favourites'
                        : 'Add to Favourites',
                    icon: Icon(
                      favouritesController.favourites.any((fav) => fav.url == apiController.details?.url)
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      color:
                          favouritesController.favourites.any((fav) => fav.url == apiController.details?.url) ? Colors.red : null,
                    ),
                    onPressed: () {
                      if (apiController.details?.url != null) {
                        favouritesController.addToFavourites(
                            apiController.details!.url!, widget.source ?? apiController.currentSource);
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
                FontSettingsButton(),
                if (apiController.details != null && apiController.details!.url != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Details',
                    onPressed: () {
                      apiController.fetchDetails(apiController.details!.url!,
                          source: widget.source,
                          refresh: true,
                          canCacheChapters: widget.canCacheChapters,
                          canCacheNovel: widget.canCacheNovel);
                    },
                  ),
                if ((apiController.details != null && apiController.details!.fullUrl != null) ||
                    (apiController.chapter != null && apiController.chapter!.fullUrl != null))
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    tooltip: 'Open in Browser',
                    onPressed: () async {
                      final url = apiController.chapter?.fullUrl ?? apiController.details?.fullUrl;
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
            body: body(context),
          ),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
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
            controller: _tabController,
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
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.tertiary,
            ],
            tabs: [
              Text(
                'Details',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Text(
                'Chapters (${apiController.chapters?.length ?? 0})',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
            children: [
              detailsView(context),
              ChapterListView(chaptersScrollController: _chaptersScrollController, source: widget.source),
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
  }

  Widget detailsView(BuildContext context) {
    Widget placeHolderImage = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Adjust the radius as needed
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      height: 310,
      width: 310,
      child: const Icon(
        Icons.image,
        size: 50,
      ),
    );
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 310,
                          height: 310,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12), // Adjust the radius as needed
                            color: Theme.of(context).colorScheme.surfaceContainer,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => placeHolderImage,
                    ),
                  )
                : placeHolderImage,
            const SizedBox(height: 8),
            metaDetails(context),
            if (apiController.details!.tags.isNotEmpty) const SizedBox(height: 8),
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
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  apiController.details!.summary,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                      ),
                ),
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
          color: Theme.of(context).colorScheme.surfaceContainer,
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
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            LabeledText(
              label: 'Status',
              text: ' ${apiController.details!.status}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            LabeledText(
              label: 'Genre',
              text: apiController.details!.genre.join(', '),
              softWrap: true,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
