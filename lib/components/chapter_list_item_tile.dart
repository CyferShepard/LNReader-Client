import 'package:flutter/material.dart';
import 'package:light_novel_reader_client/extensions/context_extensions.dart';

class ChapterListItemTile extends StatelessWidget {
  final String title;

  final double? position;
  final bool selected;
  final bool isChecked;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChapterListItemTile({
    super.key,
    required this.title,
    this.position,
    this.selected = false,
    this.isChecked = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.isTabletOrDesktop ? Theme.of(context).colorScheme.tertiary : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          border: Border(
            left: BorderSide(
              color: selected && !isChecked ? Theme.of(context).colorScheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: ListTile(
          style: Theme.of(context).listTileTheme.style,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: isChecked
              ? Theme.of(context).colorScheme.primary
              : (selected ? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.surfaceContainerHighest),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isChecked ? Theme.of(context).colorScheme.onPrimary : null,
            ),
          ),
          subtitle: position != null
              ? Text(
                  '${(position! * 100).toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: isChecked ? Theme.of(context).colorScheme.onPrimary : null,
                  ),
                )
              : SizedBox(height: 14),
          trailing: position != null && position == 1 ? const Icon(Icons.check_circle) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
