import 'package:flutter/material.dart';

class DefaultPlaceholderImage extends StatelessWidget {
  const DefaultPlaceholderImage({super.key, this.imageHeight = 230, this.maxWidth = 200});
  final double imageHeight; // Default image height
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: maxWidth / imageHeight,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Center(
            child: SizedBox(
          height: imageHeight,
          width: maxWidth,
          child: const Icon(Icons.image, size: 50),
        )),
      ),
    );
  }
}
