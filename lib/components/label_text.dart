import 'package:flutter/material.dart';

class LabeledText extends StatelessWidget {
  const LabeledText({
    super.key,
    required this.label,
    required this.text,
    this.labelStyle,
    this.style,
    this.softWrap = false,
    this.maxLines,
  });

  final String label;
  final String text;
  final TextStyle? labelStyle;
  final TextStyle? style;
  final bool softWrap;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: labelStyle ??
              Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
        ),
        Expanded(
          child: Text(
            text,
            softWrap: softWrap,
            maxLines: maxLines,
            style: style ??
                Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
