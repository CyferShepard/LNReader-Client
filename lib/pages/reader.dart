import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/font_settings.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/chapters.dart';
import 'package:light_novel_reader_client/models/history.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key, this.showHeader = true, this.source});

  final bool showHeader;
  final String? source;

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  late Worker _chapterWorker;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      ChapterListItem? chapterMeta =
          apiController.chapters?.firstWhereOrNull((chapter) => chapter.url == apiController.chapter?.url);
      if (apiController.details != null && apiController.chapter != null && chapterMeta != null) {
        // Debounce saving position
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 400), () {
          double ratio = 0.0;
          if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
            ratio = _scrollController.offset / _scrollController.position.maxScrollExtent;
          }
          // double roundedRatio = double.parse(ratio.toStringAsFixed(5));
          // print('Saving position: $ratio for chapter: ${apiController.chapter!.title}');
          historyController.addToHistory(
            novel: apiController.details!,
            chapter: chapterMeta,
            source: widget.source ?? apiController.currentSource,
            page: 0,
            position: ratio, // Save ratio instead of absolute offset
          );
        });
      }
    });

    _chapterWorker = ever(apiController.chapterRx, (_) {
      // Wait for the next frame so the scroll view is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final chapter = apiController.chapter;
        if (chapter == null) return;
        History? history = historyController.history.firstWhereOrNull((h) => h.url == chapter.url);
        final ratio = (history?.position ?? 0.0).toDouble();
        if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
          final max = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(ratio * max);
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      History? history = historyController.history.firstWhereOrNull((h) => h.url == apiController.chapter?.url);
      final ratio = (history?.position ?? 0.0).toDouble();
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        final max = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(ratio * max);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showHeader
          ? AppBar(
              title: const Text('Reader'),
              actions: [
                Obx(() {
                  if (!apiController.isChapterLoading &&
                      apiController.chapter?.previousPage != null &&
                      apiController.chapter!.previousPage!.isNotEmpty) {
                    return Tooltip(
                      message: 'Previous Chapter',
                      child: IconButton(
                        icon: const Icon(Icons.navigate_before),
                        onPressed: () {
                          apiController.fetchChapter(
                            apiController.chapter!.previousPage!,
                            source: widget.source,
                          );
                        },
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
                SizedBox(width: 12),
                Obx(() {
                  if (!apiController.isChapterLoading &&
                      apiController.chapter?.nextPage != null &&
                      apiController.chapter!.nextPage!.isNotEmpty) {
                    return Tooltip(
                      message: 'Next Chapter',
                      child: IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed: () {
                          apiController.fetchChapter(apiController.chapter!.nextPage!, source: widget.source);
                        },
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
                SizedBox(width: 12),
                FontSettingsButton(),
                SizedBox(width: 12),
              ],
            )
          : null,
      body: Obx(() {
        if (apiController.isChapterLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (apiController.chapter == null) {
          return const Center(
            child: Text('No Chapter selected.'),
          );
        }

        return mainReaderView(context);
      }),
    );
  }

  Padding mainReaderView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.showHeader ? 0 : 16.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.showHeader) ...[
                    Text(
                      apiController.chapter!.title,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      thickness: 1,
                    ),
                  ],
                  Expanded(
                    child: Obx(() => SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              widget.showHeader
                                  ? '${apiController.chapter!.title}\n\n${apiController.chapter!.content}'
                                  : apiController.chapter!.content,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(height: uiController.lineHeight, fontSize: uiController.fontSize),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
