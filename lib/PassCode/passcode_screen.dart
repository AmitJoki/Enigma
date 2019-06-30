import 'dart:async';
import 'dart:math' as math;
import 'package:Enigma/security.dart';
import 'package:Enigma/utils.dart';
import 'package:flutter/material.dart';
import 'package:Enigma/PassCode/circle.dart';
import 'package:Enigma/PassCode/keyboard.dart';
import 'package:Enigma/PassCode/shake_curve.dart';
import 'package:Enigma/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef PasswordEnteredCallback = void Function(String text);

class PasscodeScreen extends StatefulWidget {
  final String title, question, answer, phoneNo;
  final int passwordDigits;
  final PasswordEnteredCallback passwordEnteredCallback;
  final String cancelLocalizedText;
  final String deleteLocalizedText;
  final Stream<bool> shouldTriggerVerification;
  final Widget bottomWidget;
  final bool shouldPop;
  final CircleUIConfig circleUIConfig;
  final KeyboardUIConfig keyboardUIConfig;
  final bool wait, authentication;
  final SharedPreferences prefs;
  final Function onSubmit;

  PasscodeScreen(
      {Key key,
      @required this.onSubmit,
      @required this.title,
      this.passwordDigits = 6,
      this.prefs,
      @required this.passwordEnteredCallback,
      @required this.cancelLocalizedText,
      @required this.deleteLocalizedText,
      @required this.shouldTriggerVerification,
      @required this.wait,
      this.circleUIConfig,
      this.keyboardUIConfig,
      this.bottomWidget,
      this.authentication = false,
      this.question,
      this.answer,
      this.phoneNo,
      this.shouldPop = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<bool> streamSubscription;
  String enteredPasscode = '';
  AnimationController controller;
  Animation<double> animation;
  bool _isValid = false;
  SharedPreferences prefs;
  TextEditingController _answer = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int passcodeTries = 0, answerTries;
  bool forgetVisible = false;

  bool forgetActionable() {
    int tries = prefs.getInt(ANSWER_TRIES) ?? 0;
    int lastAnswered = prefs.getInt(LAST_ANSWERED) ??
        DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch;

    DateTime lastTried = DateTime.fromMillisecondsSinceEpoch(lastAnswered);
    return (tries <= TRIES_THRESHOLD ||
        DateTime.now().isAfter(lastTried.add(
            Duration(minutes: math.pow(TIME_BASE, tries - TRIES_THRESHOLD)))));
  }

  @override
  void initState() {
    super.initState();
    if (widget.authentication) {
      prefs = widget.prefs;
      passcodeTries = widget.prefs.getInt(PASSCODE_TRIES) ?? 0;
      forgetVisible = passcodeTries > TRIES_THRESHOLD - 1;
      answerTries = widget.prefs.getInt(ANSWER_TRIES) ?? 0;
    }
    streamSubscription = widget.shouldTriggerVerification.listen((isValid) {
      _showValidation(isValid);
      setState(() {
        _isValid = isValid;
      });
    });
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation curve =
        CurvedAnimation(parent: controller, curve: ShakeCurve());
    animation = Tween(begin: 0.0, end: 10.0).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            enteredPasscode = '';
            controller.value = 0;
          });
        }
      })
      ..addListener(() {
        setState(() {
          // the animation object’s value is the changed state
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Enigma.getNTPWrappedWidget(Scaffold(
      appBar: widget.wait
          ? AppBar(
              backgroundColor: enigmaBlack,
              title: Text(widget.title),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: _isValid
                      ? () {
                          if (widget.onSubmit != null)
                            widget.onSubmit(enteredPasscode);
                          Navigator.maybePop(context);
                        }
                      : null,
                )
              ],
            )
          : null,
      backgroundColor: enigmaBlack,
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.wait
                  ? 'Use a passcode that is hard to guess.'
                  : widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, left: 60, right: 60),
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildCircles(),
              ),
            ),
            IntrinsicHeight(
              child: Container(
                margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
                child: Keyboard(
                  onDeleteCancelTap: _onDeleteCancelButtonPressed,
                  onKeyboardTap: _onKeyboardButtonPressed,
                  shouldShowCancel: enteredPasscode.isEmpty,
                  cancelLocalizedText: widget.cancelLocalizedText,
                  deleteLocalizedText: widget.deleteLocalizedText,
                  keyboardUIConfig: widget.keyboardUIConfig != null
                      ? widget.keyboardUIConfig
                      : KeyboardUIConfig(),
                ),
              ),
            ),
            widget.bottomWidget != null ? widget.bottomWidget : Container(),
            widget.authentication && forgetVisible
                ? FlatButton(
                    onPressed: () {
                      if (forgetActionable()) {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return Theme(
                                  child: AlertDialog(
                                    title: Text(widget.question),
                                    content: SingleChildScrollView(
                                        child: Form(
                                      key: _formKey,
                                      child: Column(children: <Widget>[
                                        TextFormField(
                                          controller: _answer,
                                          decoration: InputDecoration(
                                              labelText: 'Security Answer'),
                                          validator: (val) {
                                            if (val.isEmpty)
                                              return "Answer cannot be empty!";
                                            if (Enigma.getHashedAnswer(val) !=
                                                widget.answer) {
                                              setState(() {
                                                answerTries += 1;
                                                prefs.setInt(
                                                    ANSWER_TRIES, answerTries);
                                                prefs.setInt(
                                                    LAST_ANSWERED,
                                                    DateTime.now()
                                                        .millisecondsSinceEpoch);
                                                if (answerTries >
                                                    TRIES_THRESHOLD) {
                                                  Enigma.toast(
                                                      'Try after ${math.pow(TIME_BASE, answerTries - TRIES_THRESHOLD)} minutes');
                                                  Navigator.maybePop(context);
                                                }
                                              });
                                              return 'Wrong answer';
                                            } else {
                                              prefs.setInt(ANSWER_TRIES, 0);
                                              prefs.setInt(PASSCODE_TRIES,
                                                  0); // reset tries
                                              Navigator.pushReplacement(
                                                  context,
                                                  new MaterialPageRoute(
                                                      builder: (context) =>
                                                          new Security(
                                                            widget.phoneNo,
                                                            title:
                                                                'Update Security',
                                                            shouldPop: true,
                                                            setPasscode: true,
                                                            answer:
                                                                widget.answer,
                                                            onSuccess: () {
                                                              Navigator.popUntil(
                                                                  context,
                                                                  (route) => route
                                                                      .isFirst);
                                                            },
                                                          )));
                                            }
                                            return null;
                                          },
                                        )
                                      ]),
                                    )),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('Done'),
                                        onPressed: () {
                                          _formKey.currentState.validate();
                                        },
                                      )
                                    ],
                                  ),
                                  data: EnigmaTheme);
                            });
                      } else
                        Enigma.toast('Try again later.');
                    },
                    child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text('Forgot Password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w300))),
                  )
                : null
          ].where((o) => o != null).toList(),
        ),
      )),
    ));
  }

  List<Widget> _buildCircles() {
    var list = <Widget>[];
    var config = widget.circleUIConfig != null
        ? widget.circleUIConfig
        : CircleUIConfig();
    config.extraSize = animation.value;
    for (int i = 0; i < widget.passwordDigits; i++) {
      list.add(Circle(
        filled: i < enteredPasscode.length,
        circleUIConfig: config,
      ));
    }
    return list;
  }

  _onDeleteCancelButtonPressed() {
    if (enteredPasscode.isNotEmpty) {
      setState(() {
        enteredPasscode =
            enteredPasscode.substring(0, enteredPasscode.length - 1);
        widget.passwordEnteredCallback(enteredPasscode);
      });
    } else {
      Navigator.maybePop(context);
    }
  }

  _onKeyboardButtonPressed(String text) {
    setState(() {
      if (enteredPasscode.length < widget.passwordDigits) {
        enteredPasscode += text;
        widget.passwordEnteredCallback(enteredPasscode);
        if (enteredPasscode.length == widget.passwordDigits) {
          if (widget.authentication &&
              prefs.getInt(PASSCODE_TRIES) > TRIES_THRESHOLD - 1) {
            if (forgetVisible != true) {
              setState(() {
                forgetVisible = true;
              });
            }
          }
        }
      }
    });
  }

  @override
  didUpdateWidget(PasscodeScreen old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerVerification != old.shouldTriggerVerification) {
      streamSubscription.cancel();
      streamSubscription = widget.shouldTriggerVerification.listen((isValid) {
        _showValidation(isValid);
        setState(() {
          _isValid = isValid;
        });
      });
    }
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
    streamSubscription.cancel();
  }

  _showValidation(bool isValid) {
    if (!widget.wait) {
      if (isValid && widget.shouldPop) {
        Navigator.maybePop(context);
      } else {
        controller.forward();
      }
    }
  }
}
