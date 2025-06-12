import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:light_novel_reader_client/globals.dart'; // adjust if needed

class FontSettingsButton extends StatefulWidget {
  const FontSettingsButton({super.key});

  @override
  State<FontSettingsButton> createState() => _FontSettingsButtonState();
}

class _FontSettingsButtonState extends State<FontSettingsButton> {
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
                            Row(
                              children: [
                                const Icon(Icons.format_size),
                                const SizedBox(width: 8),
                                const Text('Font Size'),
                                Expanded(
                                  child: Slider(
                                    min: 10,
                                    max: 30,
                                    divisions: 20,
                                    value: uiController.fontSize,
                                    onChanged: (v) => uiController.fontSize = v,
                                  ),
                                ),
                                Text(uiController.fontSize.toStringAsFixed(0)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.format_line_spacing),
                                const SizedBox(width: 8),
                                const Text('Line Height'),
                                Expanded(
                                  child: Slider(
                                    min: 1.0,
                                    max: 3.0,
                                    divisions: 20,
                                    value: uiController.lineHeight,
                                    onChanged: (v) => uiController.lineHeight = v,
                                  ),
                                ),
                                Text(uiController.lineHeight.toStringAsFixed(2)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.brightness_6),
                                const SizedBox(width: 8),
                                const Text('Dark Mode'),
                                const Spacer(),
                                Obx(() => Switch(
                                      value: themeMode.value == ThemeMode.dark,
                                      onChanged: (val) {
                                        uiController.toggleDarkMode();
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
      icon: const Icon(Icons.text_fields),
      tooltip: 'Font Settings',
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
