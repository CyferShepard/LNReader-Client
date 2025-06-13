import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:light_novel_reader_client/globals.dart';

class _DefaultPlaceholderImage extends StatelessWidget {
  const _DefaultPlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.book, size: 50),
    );
  }
}

class NovelCard extends StatelessWidget {
  const NovelCard({
    super.key,
    required this.novelCardData,
    this.novelCardChapterData,
    this.onTap,
    this.maxWidth = 200,
    this.aspectRatio = 200 / 410, // Default aspect ratio
    this.placeHolderImage = const _DefaultPlaceholderImage(),
  });

  final NovelCardData novelCardData;
  final NovelCardChapterData? novelCardChapterData;
  final VoidCallback? onTap;
  final double maxWidth;
  final double aspectRatio; // Default aspect ratio
  final Widget placeHolderImage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth), // Set your max width here
        child: AspectRatio(
          aspectRatio: aspectRatio, // Maintain this ratio
          child: Card(
            elevation: 2,
            child: InkWell(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: (novelCardData.cover.isNotEmpty)
                          ? Image.network(
                              '${client.baseUrl}/proxy/imageProxy?imageUrl=${novelCardData.cover}',
                              fit: BoxFit.cover,
                              width: maxWidth,
                              errorBuilder: (context, error, stackTrace) => placeHolderImage,
                            )
                          : placeHolderImage,
                    ),
                    Container(
                      height: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) *
                          (novelCardChapterData != null ? 8.5 : 4), // 2 lines + spacing
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      padding: const EdgeInsets.all(1.0),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Tooltip(
                          message: novelCardData.title,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * (3), // 2 lines + spacing
                                child: Text(
                                  novelCardData.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              if (novelCardChapterData != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Chapter: ${novelCardChapterData!.index}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                      ),
                                ),
                                if (novelCardChapterData!.date != null) const SizedBox(height: 4),
                                if (novelCardChapterData!.date != null)
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm:ss').format(novelCardChapterData!.date!),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSecondary,
                                        ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

  NovelCardData({
    required this.title,
    required this.cover,
    required this.url,
    required this.source,
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
