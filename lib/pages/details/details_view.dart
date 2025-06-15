import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';
import 'package:light_novel_reader_client/pages/details/details_desktop_view.dart';
import 'package:light_novel_reader_client/pages/details/details_mobile_view.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({super.key, this.source, required this.canCacheChapters, required this.canCacheNovel});

  final String? source;
  final bool canCacheChapters;
  final bool canCacheNovel;

  @override
  Widget build(BuildContext context) {
    return context.isTabletOrDesktop
        ? DetailsDesktopPage(source: source, canCacheChapters: canCacheChapters, canCacheNovel: canCacheNovel)
        : DetailsMobilePage(source: source, canCacheChapters: canCacheChapters, canCacheNovel: canCacheNovel);
  }
}
