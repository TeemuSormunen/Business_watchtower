import 'package:flutter/material.dart';

import 'main.dart';

///this class is used to create navigation tool at the bottom
class FancyFab extends StatefulWidget {
  final Map<String, Function()> onPressed;
  final Map<String, String> tooltips;
  final Map<String, Icon> icons;

  FancyFab({this.onPressed, this.tooltips, this.icons});

  @override
  FancyFabState createState() => FancyFabState(onPressed, tooltips, icons);
}

class FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  Map<String, Function()> onPressedStuff;
  Map<String, String> tooltips;
  Map<String, Icon> icons;

  FancyFabState(this.onPressedStuff, this.tooltips, this.icons);

  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  List<Widget> childrenOvCreatorOvButtons() {
    List<Widget> widgets = new List();
    int i = 1;
    widgets.add(toggle());
    for (String key in onPressedStuff.keys) {
      Function functionOvButton = onPressedStuff[key];
      Icon icon = icons[key];
      widgets.add(Transform(
          transform: Matrix4.translationValues(
              0.0,
              _translateButton.value * i,
              0.0
          ),
          child: funcBuild(function: functionOvButton, tooltipString: key, iconData: icon)
      ));
      i++;
    }
    widgets = widgets.reversed.toList();
    return widgets;
  }

  Column creatorOvButtons() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: childrenOvCreatorOvButtons()
    );
  }

  Widget funcBuild({Function function, String tooltipString, Icon iconData}) {
    return Container(
        child: FloatingActionButton(
          heroTag: tooltipString,
          onPressed: function,
          tooltip: tooltipString,
          child: iconData,
        )
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        elevation: 8.0,
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return creatorOvButtons();
  }
}