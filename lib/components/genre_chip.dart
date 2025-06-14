import 'package:flutter/material.dart';

class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.genre, this.textStyle, this.decoration, this.margin, this.padding});
  final String genre;
  final TextStyle? textStyle;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      margin: margin,
      padding: padding,
      child: Text(
        genre,
        style: textStyle ??
            TextStyle(
              fontSize: 12.0,
              color: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
