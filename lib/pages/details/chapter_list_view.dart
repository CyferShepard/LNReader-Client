import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/chapter_list_item_tile.dart';
import 'package:light_novel_reader_client/globals.dart';

class ChapterListView extends StatefulWidget {
  const ChapterListView({
    super.key,
    required ScrollController chaptersScrollController,
    required this.source,
  }) : _chaptersScrollController = chaptersScrollController;

  final ScrollController _chaptersScrollController;
  final String? source;

  @override
  State<ChapterListView> createState() => _ChapterListViewState();
}

class _ChapterListViewState extends State<ChapterListView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        controller: widget._chaptersScrollController,
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
