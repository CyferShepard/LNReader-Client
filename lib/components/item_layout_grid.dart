import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:light_novel_reader_client/components/novel_card.dart';

class ItemCardLayoutGrid extends StatelessWidget {
  const ItemCardLayoutGrid({
    super.key,
    required this.items,
    this.itemWidth = 200,
    this.itemHeight = 410,
    this.horizontalGap = 24,
    this.verticalGap = 40,
  });

  final List<NovelCard> items;
  final double itemWidth;
  final double itemHeight;
  final double horizontalGap;
  final double verticalGap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        // Calculate the max number of columns that can fit
        int columns = (availableWidth + horizontalGap) ~/ (itemWidth + horizontalGap);
        columns = columns > 0 ? columns : 1;
        final int rows = (items.length / columns).ceil();

        // Calculate the actual width for each item so they fill the grid exactly
        final double totalGap = horizontalGap * (columns - 1);
        final double actualItemWidth = (availableWidth - totalGap) / columns;

        return SingleChildScrollView(
          child: SizedBox(
            width: availableWidth,
            child: LayoutGrid(
              columnSizes: List.generate(columns, (_) => FixedTrackSize(actualItemWidth)),
              rowSizes: List.generate(rows, (_) => FixedTrackSize(itemHeight)),
              columnGap: horizontalGap,
              rowGap: verticalGap,
              children: [
                for (int i = 0; i < items.length; i++)
                  items[i].withGridPlacement(
                    columnStart: i % columns,
                    rowStart: i ~/ columns,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
