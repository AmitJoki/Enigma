import 'package:flutter/material.dart';

typedef KeyboardTapCallback = void Function(String text);

class KeyboardUIConfig {
  final double digitSize;
  final double digitBorderWidth;
  final TextStyle digitTextStyle;
  final TextStyle deleteButtonTextStyle;
  final Color primaryColor;
  final Color digitFillColor;
  final EdgeInsetsGeometry keyboardRowMargin;

  KeyboardUIConfig({
    this.digitSize = 80,
    this.digitBorderWidth = 1,
    this.keyboardRowMargin = const EdgeInsets.only(top: 15),
    this.primaryColor = Colors.white,
    this.digitFillColor = Colors.transparent,
    this.digitTextStyle = const TextStyle(fontSize: 30, color: Colors.white),
    this.deleteButtonTextStyle =
        const TextStyle(fontSize: 16, color: Colors.white),
  });
}

class Keyboard extends StatelessWidget {
  final KeyboardUIConfig keyboardUIConfig;
  final GestureTapCallback onDeleteCancelTap;
  final KeyboardTapCallback onKeyboardTap;
  final bool shouldShowCancel;
  final String cancelLocalizedText;
  final String deleteLocalizedText;

  Keyboard(
      {Key key,
      @required this.keyboardUIConfig,
      @required this.onDeleteCancelTap,
      @required this.onKeyboardTap,
      this.shouldShowCancel = true,
      @required this.cancelLocalizedText,
      @required this.deleteLocalizedText})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _buildKeyboard();

  Widget _buildKeyboard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('1'),
            _buildKeyboardDigit('2'),
            _buildKeyboardDigit('3'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('4'),
            _buildKeyboardDigit('5'),
            _buildKeyboardDigit('6'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('7'),
            _buildKeyboardDigit('8'),
            _buildKeyboardDigit('9'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit(''), // padding the space for the other two
            _buildKeyboardDigit('0'),
            _buildDeleteButton()
          ],
        ),
      ],
    );
  }

  Widget _buildKeyboardDigit(String text) {
    return Container(
      margin: keyboardUIConfig.keyboardRowMargin,
      width: keyboardUIConfig.digitSize,
      height: keyboardUIConfig.digitSize,
      child: ClipOval(
        child: Material(
          color: keyboardUIConfig.digitFillColor,
          child: text.isNotEmpty
              ? InkWell(
                  highlightColor: keyboardUIConfig.primaryColor,
                  splashColor: keyboardUIConfig.primaryColor.withOpacity(0.4),
                  onTap: () {
                    onKeyboardTap(text);
                  },
                  child: Center(
                    child: Text(
                      text,
                      style: keyboardUIConfig.digitTextStyle,
                    ),
                  ),
                )
              : Container(width: 0, height: 0),
        ),
      ),
      decoration: text.isNotEmpty
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: keyboardUIConfig.primaryColor,
                  width: keyboardUIConfig.digitBorderWidth),
            )
          : null,
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      margin: keyboardUIConfig.keyboardRowMargin,
      width: keyboardUIConfig.digitSize,
      height: keyboardUIConfig.digitSize,
      child: ClipOval(
        child: Material(
          color: keyboardUIConfig.digitFillColor,
          child: InkWell(
            highlightColor: keyboardUIConfig.primaryColor,
            splashColor: keyboardUIConfig.primaryColor.withOpacity(0.4),
            onTap: onDeleteCancelTap,
            child: Center(
              child: Text(
                shouldShowCancel ? cancelLocalizedText : deleteLocalizedText,
                style: keyboardUIConfig.deleteButtonTextStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
