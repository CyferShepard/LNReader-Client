import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/controller/favourites_controller.dart';
import 'package:light_novel_reader_client/extensions/string_extensions.dart';
import 'package:light_novel_reader_client/globals.dart'; // adjust if needed

class FavouritesSortButton extends StatefulWidget {
  const FavouritesSortButton({super.key});

  @override
  State<FavouritesSortButton> createState() => _FavouritesSortButtonState();
}

class _FavouritesSortButtonState extends State<FavouritesSortButton> {
  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _showDropdown(BuildContext context) {
    final RenderBox renderBox = _iconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dropdownWidth = screenWidth < 600 ? screenWidth - 32.0 : 300.0;
        double left = offset.dx;
        // Clamp left so the dropdown doesn't overflow the right edge
        if (left + dropdownWidth > screenWidth) {
          left = screenWidth - dropdownWidth - 8; // 8px margin from right
          if (left < 8) left = 8; // 8px margin from left
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
                    child: Obx(() => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (SortBy sortOption in SortBy.values)
                              ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: Text(sortOption.name.splitCamelCaseAndCapitalize()),
                                leading: Radio<SortBy>(
                                  value: sortOption,
                                  groupValue: favouritesController.sortOrder,
                                  onChanged: (value) {
                                    if (value != null) {
                                      favouritesController.sortOrder = value;
                                      // _hideDropdown();
                                    }
                                  },
                                ),
                              ),
                            const Divider(),
                            Row(
                              children: [
                                const SizedBox(width: 4),
                                Icon(favouritesController.sortAsc ? Icons.arrow_upward : Icons.arrow_downward),
                                const SizedBox(width: 8),
                                const Text('Sort Ascending'),
                                const Spacer(),
                                Obx(() => Switch(
                                      value: favouritesController.sortAsc,
                                      onChanged: (val) {
                                        favouritesController.sortAsc = val;
                                      },
                                    )),
                              ],
                            ),
                          ],
                        )),
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
      icon: const Icon(Icons.sort),
      tooltip: 'Sort Options',
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
