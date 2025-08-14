import 'package:flutter/material.dart';

class SideNavBarController extends ChangeNotifier {
  int _selectedIndex = 0;
  int _itemsCount = 0;
  bool _collapsed = true;
  bool _showLabels = false; // decouple label visibility from width (for fade)

  Duration _lastDuration = const Duration(milliseconds: 250);
  set animationDuration(Duration d) => _lastDuration = d;

  int get selectedIndex => _selectedIndex;
  int get itemsCount => _itemsCount;
  bool get collapsed => _collapsed;
  bool get showLabels => _showLabels;

  set itemsCount(int count) {
    _itemsCount = count;
    notifyListeners();
  }

  void select(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  Future<void> toggleCollapse({Duration? duration}) async {
    final d = duration ?? _lastDuration;
    // Expanding: grow width first, then fade labels in
    if (_collapsed) {
      _collapsed = false;
      notifyListeners();
      // wait a frame so width anim starts
      await Future.delayed(d * 0.6);
      _showLabels = true;
      notifyListeners();
    } else {
      // Collapsing: fade labels out first, then shrink width
      _showLabels = false;
      notifyListeners();
      await Future.delayed(d * 0.6);
      _collapsed = true;
      notifyListeners();
    }
  }
}

class SideNavBar extends StatelessWidget {
  final List<NavBarItem> items;
  final List<NavBarItem>? bottomItems;
  final SideNavBarController controller;
  final double width;
  final double collapsedWidth;
  final SideNavBarStyle? style;
  final Duration animationDuration;
  final Curve animationCurve;

  const SideNavBar({
    super.key,
    required this.items,
    this.bottomItems,
    required this.controller,
    this.width = 220,
    this.collapsedWidth = 60,
    this.style,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    final navBarStyle = style ?? SideNavBarStyle();
    controller.itemsCount = items.length;
    controller.animationDuration = animationDuration;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final bool isCollapsed = controller.collapsed;
        return AnimatedContainer(
          color: navBarStyle.backgroundColor ?? Theme.of(context).colorScheme.primary,
          duration: animationDuration,
          curve: animationCurve,
          width: isCollapsed ? collapsedWidth : width,
          child: Column(
            children: [
              AnimatedAlign(
                alignment: isCollapsed ? Alignment.center : Alignment.centerRight,
                duration: animationDuration,
                curve: animationCurve,
                child: IconButton(
                  icon: Icon(
                    isCollapsed ? Icons.menu : Icons.menu_open,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: controller.toggleCollapse,
                  tooltip: isCollapsed ? 'Expand' : 'Collapse',
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final selected = controller.selectedIndex == index;
                        final item = items[index];
                        return _HoverableListTile(
                          selected: selected,
                          navBarStyle: navBarStyle,
                          isCollapsed: isCollapsed,
                          item: item,
                          onTap: () => controller.select(index),
                          animationDuration: animationDuration,
                        );
                      },
                    ),
                    if (bottomItems != null)
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: bottomItems!.length,
                        itemBuilder: (context, index) {
                          // final selected = controller.selectedIndex == index;
                          final item = bottomItems![index];
                          return _HoverableListTile(
                            selected: false,
                            navBarStyle: navBarStyle,
                            isCollapsed: isCollapsed,
                            item: item,
                            onTap: () => item.onTap,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HoverableListTile extends StatefulWidget {
  final bool selected;
  final SideNavBarStyle navBarStyle;
  final bool isCollapsed;
  final NavBarItem item;
  final VoidCallback onTap;
  final Duration animationDuration;

  const _HoverableListTile({
    required this.selected,
    required this.navBarStyle,
    required this.isCollapsed,
    required this.item,
    required this.onTap,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<_HoverableListTile> createState() => _HoverableListTileState();
}

class _HoverableListTileState extends State<_HoverableListTile> {
  bool _hovering = false;

  Widget _buildTitle(BuildContext context) {
    final text = Text(
      widget.item.label,
      softWrap: false,
      overflow: TextOverflow.fade,
      style: widget.selected
          ? widget.navBarStyle.selectedItemStyle?.textStyle ?? Theme.of(context).textTheme.bodyLarge
          : widget.navBarStyle.textStyle ?? Theme.of(context).textTheme.bodyMedium,
    );

    // Controller now controls when labels show (passed via isCollapsed & showLabels decoupled)
    // We infer showLabels via an inherited flag: use widget.isCollapsed only for tooltip,
    // fade based on a new flag we pass (add parameter showLabels to _HoverableListTile if needed)
    return AnimatedOpacity(
      opacity: (context.findAncestorWidgetOfExactType<SideNavBar>()?.controller.showLabels ?? false) ? 1.0 : 0.0,
      duration: widget.animationDuration,
      curve: Curves.fastOutSlowIn,
      // Keep layout space so fade is visible before width shrinks
      child: IgnorePointer(
        ignoring: !(context.findAncestorWidgetOfExactType<SideNavBar>()?.controller.showLabels ?? false),
        child: Align(alignment: Alignment.centerLeft, child: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = widget.selected
        ? widget.navBarStyle.selectedItemStyle?.backgroundColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.1)
        : _hovering
            ? Theme.of(context).hoverColor
            : widget.navBarStyle.tileColor;

    // Use smaller icon and less padding when collapsed

    final EdgeInsetsGeometry contentPadding =
        widget.isCollapsed ? const EdgeInsets.only(left: 18) : (widget.navBarStyle.tilePadding ?? EdgeInsets.only(left: 18));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        color: highlightColor,
        child: Tooltip(
          message: widget.isCollapsed ? widget.item.label : "",
          child: ListTile(
            leading: Icon(
              widget.item.icon,
              size: 24,
              color: widget.selected ? widget.navBarStyle.selectedItemStyle?.iconColor : widget.navBarStyle.unselectedIconColor,
            ),
            title: _buildTitle(context),
            onTap: () {
              if (widget.item.onTap != null) {
                widget.item.onTap!();
                if (widget.item.navigateWithOnTap) {
                  widget.onTap();
                }
              } else {
                widget.onTap();
              }
            },
            shape: widget.navBarStyle.tileShape,
            contentPadding: contentPadding,
          ),
        ),
      ),
    );
  }
}

class NavBarItem {
  final String label;
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;
  final bool showInMobile;
  final bool navigateWithOnTap;

  NavBarItem(
      {required this.label,
      required this.icon,
      required this.child,
      this.onTap,
      this.showInMobile = true,
      this.navigateWithOnTap = false});
}

class SelectedItemStyle {
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? elevation;
  final double? padding;
  final double? margin;
  final Color? iconColor;

  final TextStyle? textStyle;

  SelectedItemStyle({
    this.textStyle,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.margin,
    this.iconColor,
  });
}

class SideNavBarStyle {
  final Color? backgroundColor;
  final SelectedItemStyle? selectedItemStyle;
  final double? borderRadius;
  final double? elevation;
  final Color? unselectedIconColor;
  final Color? borderColor;
  final Color? tileColor;
  final TextStyle? textStyle;
  final ShapeBorder? tileShape;
  final EdgeInsetsGeometry? tilePadding;

  SideNavBarStyle({
    this.backgroundColor,
    this.tileColor,
    this.textStyle,
    this.selectedItemStyle,
    this.tileShape,
    this.tilePadding,
    this.borderRadius,
    this.elevation,
    this.unselectedIconColor,
    this.borderColor,
  });
}
