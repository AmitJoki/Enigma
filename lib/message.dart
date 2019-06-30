import 'package:Enigma/const.dart';
import 'package:flutter/material.dart';
import 'package:Enigma/seen_provider.dart';

class Message {
  Message(Widget child,
      {@required this.timestamp,
      @required this.from,
      @required this.onTap,
      @required this.onDoubleTap,
      @required this.onDismiss,
      @required this.onLongPress,
      this.saved = false})
      : child = wrapMessage(
            child: child,
            onDismiss: onDismiss,
            onDoubleTap: onDoubleTap,
            onTap: onTap,
            onLongPress: onLongPress,
            saved: saved);

  final String from;
  final Widget child;
  final int timestamp;
  final VoidCallback onTap, onDoubleTap, onDismiss, onLongPress;
  final bool saved;
  static Widget wrapMessage(
      {@required SeenProvider child,
      @required onDismiss,
      @required onDoubleTap,
      @required onTap,
      @required onLongPress,
      @required bool saved}) {
    return child.child.isMe
        ? GestureDetector(
            child: child,
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            onLongPress: onLongPress,
          )
        : Dismissible(
            background: Align(
              child: Icon(Icons.delete_sweep, color: enigmaWhite, size: 40),
              alignment: Alignment.bottomLeft,
            ),
            key: Key(child.timestamp),
            dismissThresholds: {DismissDirection.startToEnd: 0.9},
            child: GestureDetector(
              child: child,
              onDoubleTap: onDoubleTap,
              onTap: onTap,
              onLongPress: onLongPress,
            ),
            onDismissed: (direction) {
              if (onDismiss != null) onDismiss();
            },
            direction: DismissDirection.startToEnd,
          );
  }
}
