import 'package:Enigma/seen_state.dart';
import 'package:flutter/widgets.dart';
import 'package:Enigma/bubble.dart';

class SeenProvider extends StatefulWidget {
  const SeenProvider({this.timestamp, this.data, this.child});
  final SeenState data;
  final Bubble child;
  final String timestamp;
  static of(BuildContext context) {
    _SeenInheritedProvider p =
        context.inheritFromWidgetOfExactType(_SeenInheritedProvider);
    return p.data;
  }

  @override
  State<StatefulWidget> createState() => new _SeenProviderState();
}

class _SeenProviderState extends State<SeenProvider> {
  @override
  initState() {
    super.initState();
    widget.data.addListener(didValueChange);
  }

  didValueChange() {
    if (mounted) this.setState(() {});
  }

  @override
  dispose() {
    widget.data.removeListener(didValueChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new _SeenInheritedProvider(
      data: widget.data,
      child: widget.child,
    );
  }
}

class _SeenInheritedProvider extends InheritedWidget {
  _SeenInheritedProvider({this.data, this.child})
      : _dataValue = data.value,
        super(child: child);
  final data;
  final child;
  final _dataValue;
  @override
  bool updateShouldNotify(_SeenInheritedProvider oldWidget) {
    return _dataValue != oldWidget._dataValue;
  }
}
