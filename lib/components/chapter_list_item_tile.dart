import 'package:flutter/material.dart';

class ChapterListItemTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const ChapterListItemTile({
    super.key,
    required this.title,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          border: Border(
            left: BorderSide(
              color: selected ? Color(0xFF9B6AFF) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: selected ? Color(0xFF232227) : Colors.transparent,
          hoverColor: const Color(0xFF2D2836),
          title: Text(
            title,
            style: TextStyle(
              color: selected ? Color(0xFFBCA6FF) : Colors.grey[400],
              fontSize: 14,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          onTap: onTap,
        ),
      ),
    );
  }
}
