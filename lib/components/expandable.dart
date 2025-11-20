import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final String expandText;
  final String collapseText;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
    this.expandText = 'Show more',
    this.collapseText = 'Show less',
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;
  late bool canExpand;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final span = TextSpan(text: widget.text, style: widget.style ?? DefaultTextStyle.of(context).style);
    final tp = TextPainter(
      text: span,
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width);
    canExpand = tp.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => expanded = !expanded),
      child: Column(
        children: [
          Text(
            widget.text,
            maxLines: expanded ? null : widget.maxLines,
            overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: widget.style,
          ),
          if (canExpand) const SizedBox(height: 16.0), // Add some space when expanded
          if (canExpand)
            Center(
              child: Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
