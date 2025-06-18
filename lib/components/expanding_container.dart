import 'package:flutter/material.dart';

class ExpandableContainer extends StatefulWidget {
  const ExpandableContainer({
    super.key,
    this.title,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.collapsedPadding = const EdgeInsets.all(0),
    this.expandedPadding = const EdgeInsets.all(0),
    this.expandedHeight,
    this.isExpanded = false,
    this.onToggle,
  });

  final Widget? title;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final EdgeInsets collapsedPadding;
  final EdgeInsets expandedPadding;
  final double? expandedHeight;
  final bool isExpanded;
  final Function(bool)? onToggle;

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> with SingleTickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();

    _expanded = widget.isExpanded;
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: widget.duration,
      padding: _expanded ? widget.expandedPadding : widget.collapsedPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.title != null)
                GestureDetector(
                  onTap: _toggle,
                  child: widget.title,
                ),
              AnimatedSize(
                duration: widget.duration,
                curve: widget.curve,
                child: ClipRect(
                  child: SizedBox(
                    key: const ValueKey('expanded'),
                    height: _expanded
                        ? constraints.maxHeight -
                            (widget.title is PreferredSizeWidget
                                ? (widget.title as PreferredSizeWidget).preferredSize.height
                                : 56)
                        : 2, // fallback height for title
                    child: widget.child,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
