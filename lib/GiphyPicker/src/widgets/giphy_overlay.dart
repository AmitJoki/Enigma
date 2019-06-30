import 'package:flutter/material.dart';

/// Renders a 'Powered by GIPHY' overlay image over its content
class GiphyOverlay extends StatelessWidget {
  final Widget child;

  const GiphyOverlay({this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      child,
      Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 16,
          child: IgnorePointer(
              child: Container(
                  alignment: Alignment.centerLeft,
                  color: Colors.black45,
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Image.asset(
                      'assets/giphy.png',
                      height: 14))))
    ]);
  }
}
