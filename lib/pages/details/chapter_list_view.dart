import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/chapter_list_item_tile.dart';
import 'package:light_novel_reader_client/components/text_field_editor.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChapterListView extends StatefulWidget {
  const ChapterListView({
    super.key,
    required ItemScrollController chaptersScrollController,
    required this.source,
  }) : _chaptersScrollController = chaptersScrollController;

  final ItemScrollController _chaptersScrollController;
  final String? source;

  @override
  State<ChapterListView> createState() => _ChapterListViewState();
}

class _ChapterListViewState extends State<ChapterListView> with AutomaticKeepAliveClientMixin {
  GlobalKey<TextFieldEditorState> chapterNumberFieldKey = GlobalKey<TextFieldEditorState>();
  @override
  bool get wantKeepAlive => true;

  void _scrollToChapterNumber(String text) {
    if (text.isEmpty) return;
    final chapterNum = int.tryParse(text);
    if (chapterNum == null || chapterNum < 1 || chapterNum > (apiController.chapters?.length ?? 0)) {
      chapterNumberFieldKey.currentState?.errorText = 'Invalid chapter number';
      return;
    }
    final index = chapterNum - 1;
    if (widget._chaptersScrollController.isAttached) {
      widget._chaptersScrollController.jumpTo(
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      if (apiController.isChaptersLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (apiController.chapters == null || apiController.chapters!.isEmpty) {
        return const Center(
          child: Text('No chapters available.'),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFieldEditor(
                      key: chapterNumberFieldKey,
                      initialValue: '',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        labelText: 'Go to chapter number',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => _scrollToChapterNumber(value.trim()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort_by_alpha),
                    tooltip: 'Sort Chapters',
                    onPressed: () {
                      apiController.sortAsc = !apiController.sortAsc; // Toggle sort direction
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ScrollablePositionedList.builder(
                itemScrollController: widget._chaptersScrollController,
                itemCount: apiController.chapters?.length ?? 0,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final chapter = apiController.chapters![index];
                    final isSelected = uiController.selectedChapters.contains(chapter.index);
                    final isCurrent = chapter.url == apiController.chapter?.url;
                    final position = historyController.novelhistory
                        .firstWhereOrNull((historyItem) =>
                            historyItem.novel.url == apiController.details?.url &&
                            historyItem.chapter.url == chapter.url &&
                            historyItem.source == widget.source)
                        ?.position;

                    return GestureDetector(
                      key: ValueKey(index),
                      onLongPress: () => uiController.toggleChapterSelection(chapter.index),
                      onTap: () {
                        if (uiController.multiSelectMode) {
                          uiController.toggleChapterSelection(chapter.index);
                        } else {
                          apiController.fetchChapter(chapter.url, source: widget.source);
                        }
                      },
                      child: Container(
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                        child: ChapterListItemTile(
                          title: chapter.title,
                          position: position,
                          selected: isCurrent,
                          isChecked: isSelected,
                          onTap: uiController.multiSelectMode
                              ? null
                              : () => apiController.fetchChapter(chapter.url, source: widget.source),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
