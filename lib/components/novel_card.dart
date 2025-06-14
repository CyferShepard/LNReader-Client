import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:light_novel_reader_client/components/genre_chip.dart';
import 'package:light_novel_reader_client/globals.dart';

class _DefaultPlaceholderImage extends StatelessWidget {
  const _DefaultPlaceholderImage({super.key, this.imageHeight = 230, this.maxWidth = 200});
  final double imageHeight; // Default image height
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: maxWidth / imageHeight,
      child: Container(
        color: Colors.grey[300],
        child: Center(
            child: SizedBox(
          height: imageHeight,
          width: maxWidth,
          child: const Icon(Icons.book, size: 50),
        )),
      ),
    );
  }
}

class NovelCard extends StatelessWidget {
  const NovelCard(
      {super.key,
      required this.novelCardData,
      this.novelCardChapterData,
      this.onTap,
      this.maxWidth = 200,
      this.maxHeight = 410, // Default max height
      this.imageHeight = 230, // Default image heigh
      t});

  final NovelCardData novelCardData;
  final NovelCardChapterData? novelCardChapterData;
  final VoidCallback? onTap;
  final double maxWidth;
  final double maxHeight; // Default max height
  final double imageHeight; // Default image height

  @override
  Widget build(BuildContext context) {
    final Widget placeHolderImage = _DefaultPlaceholderImage(
      maxWidth: maxWidth,
      imageHeight: imageHeight,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight), // Set your max width here
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    (novelCardData.cover.isNotEmpty)
                        ? AspectRatio(
                            aspectRatio: maxWidth / imageHeight,
                            child: Image.network(
                              '${client.baseUrl}/proxy/imageProxy?imageUrl=${novelCardData.cover}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => placeHolderImage,
                            ),
                          )
                        : placeHolderImage,
                    if (novelCardData.chapterCount != null) ...[
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Badge(
                          label: Text(
                            novelCardData.chapterCount.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                ),
                          ),
                          padding: const EdgeInsets.all(4),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Tooltip(
                    message: novelCardData.title,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * (3), // 2 lines + spacing
                          child: AutoSizeText(
                            novelCardData.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: 12,
                            maxFontSize: 16,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (novelCardChapterData != null) ...[
                          const SizedBox(height: 4),
                          AutoSizeText(
                            'Chapter: ${novelCardChapterData!.index}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                          ),
                          if (novelCardChapterData!.date != null) const SizedBox(height: 4),
                          if (novelCardChapterData!.date != null)
                            AutoSizeText(
                              maxLines: 2,
                              minFontSize: 10,
                              maxFontSize: 16,
                              overflow: TextOverflow.ellipsis,
                              DateFormat('dd/MM/yyyy HH:mm:ss').format(novelCardChapterData!.date!),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSecondary,
                                  ),
                            ),
                        ],
                        if (novelCardData.genres.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: novelCardData.genres.map((genre) {
                              return GenreChip(
                                genre: genre,
                                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSecondary,
                                    ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                // margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NovelCardData {
  final String title;
  final String cover;
  final String url;
  final String source;
  final int? chapterCount;
  final List<String> genres;

  NovelCardData({
    required this.title,
    required this.cover,
    required this.url,
    required this.source,
    this.chapterCount,
    this.genres = const [],
  });
}

class NovelCardChapterData {
  final int index;
  final DateTime? date;

  NovelCardChapterData({
    required this.index,
    this.date,
  });
}
