import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart';

class CategoriesDropdownButton extends StatefulWidget {
  final void Function(List<String>)? onChanged;

  const CategoriesDropdownButton({
    super.key,
    this.onChanged,
  });

  @override
  State<CategoriesDropdownButton> createState() => _CategoriesDropdownButtonState();
}

class _CategoriesDropdownButtonState extends State<CategoriesDropdownButton> {
  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
  }

  void _showDropdown(BuildContext context) {
    final RenderBox renderBox = _iconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dropdownWidth = screenWidth < 400 ? screenWidth - 32.0 : 300.0;
        double left = offset.dx;
        if (left + dropdownWidth > screenWidth) {
          left = screenWidth - dropdownWidth - 8;
          if (left < 8) left = 8;
        }
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _hideDropdown,
          child: Stack(
            children: [
              Positioned(
                left: left,
                top: offset.dy + size.height,
                width: dropdownWidth,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Obx(() {
                      final categories = uiController.categories.map((c) => c.name).toList();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...categories.map((cat) => CheckboxListTile(
                                title: Text(cat),
                                value: apiController.details?.categories.contains(cat),
                                onChanged: (checked) {
                                  setState(() {
                                    if (apiController.details?.categories.length == 1 && checked == false) {
                                      // Prevent unchecking the last category
                                      return;
                                    }
                                    List<String> selectedCategories = apiController.details?.categories ?? [];
                                    if (checked == true) {
                                      selectedCategories.add(cat);
                                    } else {
                                      selectedCategories.remove(cat);
                                    }
                                    if (widget.onChanged != null) {
                                      widget.onChanged!(selectedCategories);
                                    }
                                  });
                                },
                              )),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _iconKey,
      icon: const Icon(Icons.list),
      tooltip: 'Categories',
      onPressed: () {
        if (_overlayEntry == null) {
          _showDropdown(context);
        } else {
          _hideDropdown();
        }
      },
    );
  }
}
