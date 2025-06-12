import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final List<Widget>? trailing;
  final String hintText;
  final String initialValue;

  const CustomSearchBar({
    super.key,
    required this.onChanged,
    this.onClear,
    this.trailing,
    this.hintText = 'Search',
    this.initialValue = '',
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool showSearch = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  void _openSearch() {
    setState(() {
      showSearch = true;
    });
    // Optionally focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _focusNode.addListener(() {
        if (!_focusNode.hasFocus && _controller.text.isEmpty && showSearch) {
          _closeSearch();
        }
      });
    });
  }

  void _closeSearch() {
    setState(() {
      showSearch = false;
    });
    _controller.clear();
    widget.onChanged('');
    if (widget.onClear != null) widget.onClear!();
  }

  @override
  Widget build(BuildContext context) {
    if (!showSearch) {
      return IconButton(
        icon: const Icon(Icons.search),
        onPressed: _openSearch,
        tooltip: 'Search',
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            autofocus: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              prefixIcon: const Icon(Icons.search),
              hintText: widget.hintText,
            ),
          ),
          ...?widget.trailing,
          if (widget.onClear != null && _controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                widget.onChanged('');
                widget.onClear!();
              },
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeSearch,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}
