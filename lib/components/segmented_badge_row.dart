import 'package:flutter/material.dart';

class SegmentedBadgeRow extends StatelessWidget {
  const SegmentedBadgeRow({super.key, required this.items});

  final List<BadgeData> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isFirst = index == 0;
        final isLast = index == items.length - 1;

        return Tooltip(
          message: item.toolTip ?? '',
          child: Container(
            decoration: BoxDecoration(
              color: item.backgroundColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.horizontal(
                left: isFirst ? const Radius.elliptical(5, 5) : Radius.zero,
                right: isLast ? const Radius.elliptical(5, 5) : Radius.zero,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null)
                  Icon(item.icon, size: 16, color: item.textStyle?.color ?? Theme.of(context).colorScheme.primary),
                if (item.icon != null) const SizedBox(width: 4),
                Text(
                  item.label,
                  style: item.textStyle ?? Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class BadgeData {
  final String label;
  final String? toolTip;
  final IconData? icon;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  BadgeData({
    required this.label,
    this.toolTip,
    this.icon,
    this.backgroundColor,
    this.textStyle,
  });
}
