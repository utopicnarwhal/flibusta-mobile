import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

const Duration _kExpand = Duration(milliseconds: 200);

class DsExpansionTile extends StatefulWidget {
  const DsExpansionTile({
    Key key,
    this.leading,
    @required this.title,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
    this.completedIcon,
    this.description,
    this.onExpansionComplete,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  final Widget leading;

  final Widget title;

  final String description;

  final Widget completedIcon;

  final VoidCallback onExpansionComplete;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool> onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;

  /// The color to display behind the sublist when expanded.
  final Color backgroundColor;

  /// A widget to display instead of a rotating arrow icon.
  final Widget trailing;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  @override
  DsExpansionTileState createState() => DsExpansionTileState();
}

class DsExpansionTileState extends State<DsExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _backgroundColorTween = ColorTween();

  AnimationController _controller;
  Animation<double> _iconTurns;
  Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));

    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void expand() {
    if (!_isExpanded) {
      _handleTap();
    }
  }

  void collapse() {
    if (_isExpanded) {
      _handleTap();
    }
  }

  void toggle() {
    _handleTap();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward().then<void>((_) {
          widget.onExpansionComplete();
        });
      } else {
        _controller.reverse().then<void>((_) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          onTap: _handleTap,
          leading: widget.leading,
          title: widget.title,
          subtitle: _isExpanded == true && widget.description != null
              ? Text(widget.description)
              : null,
          isThreeLine: _isExpanded && widget.description != null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.trailing != null) ...[
                widget.trailing,
                SizedBox(width: 8),
              ],
              if (widget.completedIcon != null) ...[
                widget.completedIcon,
                SizedBox(width: 8),
              ],
              RotationTransition(
                turns: _iconTurns,
                child: const Icon(EvaIcons.arrowIosDownward),
              ),
            ],
          ),
        ),
        ClipRect(
          child: Align(
            heightFactor: _heightFactor.value,
            child: child,
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    _backgroundColorTween..end = widget.backgroundColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}
