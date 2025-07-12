import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/components/font_settings.dart';
import 'package:light_novel_reader_client/components/scroll_bar_vertical.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/models/chapters.dart';
import 'package:light_novel_reader_client/models/history.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> jumpToRatio(double ratio) async {
    // Wait until the scroll view is ready
    for (int i = 0; i < 10; i++) {
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        final max = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(ratio * max);
        print('Jumping to ratio: $ratio, max: $max, offset: ${_scrollController.offset}');
        return;
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final chapter = apiController.chapter;
        if (chapter == null) return;
        History? history = historyController.novelhistory.firstWhereOrNull((h) => h.url == chapter.url);
        final ratio = (history?.position ?? 0.0).toDouble();
        jumpToRatio(ratio);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      History? history = historyController.novelhistory.firstWhereOrNull((h) => h.url == apiController.chapter?.url);
      final ratio = (history?.position ?? 0.0).toDouble();
      jumpToRatio(ratio);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _chapterWorker.dispose(); // <-- Dispose the worker!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: widget.showHeader
          ? AppBar(
              scrolledUnderElevation: 0,
              title: Obx(() => Text(apiController.chapter?.title ?? 'Reader')),
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
                if (!apiController.isChapterLoading &&
                    apiController.chapter?.nextPage != null &&
                    apiController.chapter!.nextPage!.isNotEmpty)
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
                FontSettingsButton(),
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
    List colourOptions = [
      Theme.of(context).colorScheme.onSurfaceVariant,
      Theme.of(context).colorScheme.onSurface,
      Theme.of(context).colorScheme.secondary,
    ];
    return Padding(
      padding: context.isMobile ? EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8) : EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: context.isMobile),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.vertical,
                            child: SizedBox(
                              width: double.infinity,
                              child: Obx(
                                () => Column(
                                  children: [
                                    Text(
                                      '\n${apiController.chapter!.content}',
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                            height: uiController.lineHeight,
                                            fontSize: uiController.fontSize,
                                            color: colourOptions[uiController.fontColor],
                                          ),
                                    ),
                                    if (apiController.chapter?.nextPage != null &&
                                        apiController.chapter!.nextPage!.isNotEmpty) ...[
                                      const SizedBox(height: 50),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(double.infinity, 50), // Full width button
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          apiController.fetchChapter(apiController.chapter!.nextPage!, source: widget.source);
                                        },
                                        child: Text(
                                          'Next Chapter',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (context.isTabletOrDesktop) ScrollBarVertical(scrollController: _scrollController),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
