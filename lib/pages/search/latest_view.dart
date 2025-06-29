import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/novel_card.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/pages/details/details_view.dart';

class LatestView extends StatefulWidget {
  const LatestView({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  State<LatestView> createState() => _LatestViewState();
}

class _LatestViewState extends State<LatestView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _setupScrollListener() {
    widget.scrollController.addListener(() async {
      if (widget.scrollController.position.pixels >= widget.scrollController.position.maxScrollExtent - 200) {
        final latest = apiController.latest;
        if (latest != null &&
            latest.lastPage != null &&
            latest.currentPage! < latest.lastPage! &&
            !apiController.isLatestLoading) {
          await apiController.fetchLatest(
            source: apiController.currentSource,
            page: latest.currentPage! + 1,
          );
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _setupScrollListener(); // Ensure the listener is set up
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    apiController.clearSearch();
    print('LatestView disposed');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final latest = apiController.latest;
          if (widget.scrollController.hasClients &&
              widget.scrollController.position.maxScrollExtent == 0 &&
              latest != null &&
              latest.lastPage != null &&
              latest.currentPage! < latest.lastPage! &&
              !apiController.isLatestLoading) {
            print('Fetching latest results for page ${latest.currentPage! + 1}');
            await apiController.fetchLatest(
              source: apiController.currentSource,
              page: latest.currentPage! + 1,
            );
          }
        });

        if (apiController.isLatestLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (apiController.latestResults.isEmpty) {
          return const Center(
            child: Text('No results found.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            key: const PageStorageKey('latestGridView'),
            controller: widget.scrollController,
            itemCount: apiController.latestResults.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200, // Each item's max width
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 200 / 350, // width / height
            ),
            itemBuilder: (context, index) {
              final item = apiController.latestResults[index];
              return NovelCard(
                maxHeight: 350,
                novelCardData: NovelCardData(
                  title: item.title,
                  cover: item.cover,
                  cacheImage: false,
                  url: item.url,
                  source: apiController.currentSource,
                  chapterCount: item.chapterCount,
                  genres: item.genres,
                ),
                onTap: () {
                  apiController.fetchDetails(
                    item.url,
                    canCacheChapters: false,
                    canCacheNovel: false,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsView(
                        canCacheChapters: false,
                        canCacheNovel: false,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
