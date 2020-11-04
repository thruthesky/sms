import 'package:flutter/material.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  CommonAppBar({
    Key key,
    this.title,
    this.actions = const [],
    this.centerTitle = false,
    this.showBackButton = true,
    this.backgroundColor,
    this.elevation = 0,
  })  : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  final Widget title;
  final bool centerTitle;
  final bool showBackButton;
  final Color backgroundColor;
  final double elevation;
  final List<Widget> actions;

  @override
  _CommonAppBarState createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: widget.title,
      centerTitle: widget.centerTitle,
      automaticallyImplyLeading: widget.showBackButton,
      backgroundColor: widget.backgroundColor ?? Color(0xff0283d0),
      elevation: widget.elevation,
      actions: [
        if (widget.actions.isNotEmpty) ...widget.actions,
        if (Scaffold.of(context).hasEndDrawer)
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
      ],
    );
  }
}
