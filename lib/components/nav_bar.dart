import 'package:flutter/material.dart';

class SideNavBarController extends ChangeNotifier {
  int _selectedIndex = 0;
  int _itemsCount = 0;
  set itemsCount(int count) {
    _itemsCount = count;
    notifyListeners();
  }

  int get itemsCount => _itemsCount;
  bool _collapsed = true;

  int get selectedIndex => _selectedIndex;
  bool get collapsed => _collapsed;

  void select(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void toggleCollapse() {
    _collapsed = !_collapsed;
    notifyListeners();
  }
}

class SideNavBar extends StatelessWidget {
  final List<NavBarItem> items;
  final SideNavBarController controller;
  final double width;
  final double collapsedWidth;
  final SideNavBarStyle? style;
  final Duration animationDuration;
  final Curve animationCurve;

  const SideNavBar({
    super.key,
    required this.items,
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
                  icon: Icon(isCollapsed ? Icons.menu : Icons.menu_open),
                  onPressed: controller.toggleCollapse,
                  tooltip: isCollapsed ? 'Expand' : 'Collapse',
                ),
              ),
              Expanded(
                child: ListView.builder(
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
                    );
                  },
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

  const _HoverableListTile({
    required this.selected,
    required this.navBarStyle,
    required this.isCollapsed,
    required this.item,
    required this.onTap,
  });

  @override
  State<_HoverableListTile> createState() => _HoverableListTileState();
}

class _HoverableListTileState extends State<_HoverableListTile> {
  bool _hovering = false;

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
        child: ListTile(
          leading: Icon(
            widget.item.icon,
            size: 24,
            color:
                widget.selected ? widget.navBarStyle.selectedItemStyle?.textStyle?.color : widget.navBarStyle.unselectedIconColor,
          ),
          title: widget.isCollapsed
              ? null
              : Text(
                  widget.item.label,
                  softWrap: false,
                  style: widget.selected
                      ? widget.navBarStyle.selectedItemStyle?.textStyle ?? Theme.of(context).textTheme.bodyLarge
                      : widget.navBarStyle.textStyle ?? Theme.of(context).textTheme.bodyMedium,
                ),
          onTap: () {
            if (widget.item.onTap != null) {
              widget.item.onTap!();
            } else {
              widget.onTap();
            }
          },
          shape: widget.navBarStyle.tileShape,
          contentPadding: contentPadding,
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

  NavBarItem({required this.label, required this.icon, required this.child, this.onTap, this.showInMobile = true});
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
