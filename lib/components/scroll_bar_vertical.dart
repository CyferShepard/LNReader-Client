import 'package:flutter/material.dart';

class ScrollBarVertical extends StatelessWidget {
  const ScrollBarVertical({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        double ratio = 0.0;
        if (scrollController.hasClients &&
            scrollController.position.hasContentDimensions &&
            scrollController.position.maxScrollExtent > 0) {
          ratio = scrollController.offset / scrollController.position.maxScrollExtent;
        }
        return Column(
          children: [
            Expanded(
              child: RotatedBox(
                quarterTurns: 1,
                child: Slider(
                  value: ratio.clamp(0.0, 1.0),
                  onChanged: (value) {
                    if (scrollController.hasClients && scrollController.position.maxScrollExtent > 0) {
                      final max = scrollController.position.maxScrollExtent;
                      scrollController.jumpTo(value * max);
                    }
                  },
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
            ),
            SizedBox(
              height: 20,
              child: Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
