import 'dart:async';

import 'package:Enigma/main.dart';
import 'package:Enigma/security.dart';
import 'package:Enigma/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Enigma/E2EE/e2ee.dart' as e2ee;
import 'CountryPicker/country_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'const.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;
  final _phoneNo = TextEditingController();
  final _smsCode = TextEditingController();
  final _name = TextEditingController();
  String phoneCode = '+91';
  final storage = new FlutterSecureStorage();

  Country _selected = Country(
    asset: "assets/flags/in_flag.png",
    dialingCode: "91",
    isoCode: "IN",
    name: "India",
  );
  int _currentStep = 0;

  String verificationId;
  bool isLoading = false;
  dynamic isLoggedIn = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
  }

  Future<void> verifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      handleSignIn(authCredential: phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      Enigma.reportError(
          '${authException.message} Phone: ${_phoneNo.text} Country Code: $phoneCode ',
          authException.code);
      setState(() {
        isLoading = false;
      });

      Enigma.toast(
          'Authentication failed - ${authException.message}. Try again later.');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      setState(() {
        isLoading = false;
      });

      this.verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      setState(() {
        isLoading = false;
      });

      this.verificationId = verificationId;
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: (phoneCode + _phoneNo.text).trim(),
        timeout: const Duration(minutes: 2),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  Future<Null> handleSignIn({AuthCredential authCredential}) async {
    prefs = await SharedPreferences.getInstance();
    if (isLoading == false) {
      this.setState(() {
        isLoading = true;
      });
    }

    var phoneNo = (phoneCode + _phoneNo.text).trim();

    AuthCredential credential;
    if (authCredential == null)
      credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: _smsCode.text,
      );
    else
      credential = authCredential;
    FirebaseUser firebaseUser;
    try {
      firebaseUser = await firebaseAuth
          .signInWithCredential(credential)
          .catchError((err) async {
        await Enigma.reportError(err, 'signInWithCredential');
        Enigma.toast(
            'Make sure your Phone Number/OTP Code is correct and try again later.');
        if (mounted)
          setState(() {
            _currentStep = 0;
          });
        return;
      });
    } catch (e) {
      await Enigma.reportError(e, 'signInWithCredential catch block');
      Enigma.toast(
          'Make sure your Phone Number/OTP Code is correct and try again later.');
      if (mounted)
        setState(() {
          _currentStep = 0;
        });
      return;
    }

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection(USERS)
          .where(ID, isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      final pair = await e2ee.X25519().generateKeyPair();
      await storage.write(key: PRIVATE_KEY, value: pair.secretKey.toBase64());
      if (documents.isEmpty) {
        // Update data to server if new user
        await Firestore.instance.collection(USERS).document(phoneNo).setData({
          PUBLIC_KEY: pair.publicKey.toBase64(),
          COUNTRY_CODE: phoneCode,
          NICKNAME: _name.text.trim(),
          PHOTO_URL: firebaseUser.photoUrl,
          ID: firebaseUser.uid,
          PHONE: phoneNo,
          AUTHENTICATION_TYPE: AuthenticationType.passcode.index,
          ABOUT_ME: ''
        }, merge: true);

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString(ID, currentUser.uid);
        await prefs.setString(NICKNAME, _name.text.trim());
        await prefs.setString(PHOTO_URL, currentUser.photoUrl);
        await prefs.setString(PHONE, phoneNo);
        await prefs.setString(COUNTRY_CODE, phoneCode);
        unawaited(Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Security(phoneNo, setPasscode: true, onSuccess: () async {
                    unawaited(Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => EnigmaWrapper())));
                    Enigma.toast('Welcome to Enigma!');
                  }),
            )));
      } else {
        // Always set the authentication type to passcode while signing in
        // so they would have to set up fingerprint only after going through
        // passcode first.
        // This prevents using fingerprint of other users as soon as logging in.
        await Firestore.instance.collection(USERS).document(phoneNo).setData({
          AUTHENTICATION_TYPE: AuthenticationType.passcode.index,
          PUBLIC_KEY: pair.publicKey.toBase64()
        }, merge: true);
        // Write data to local
        await prefs.setString(ID, documents[0][ID]);
        await prefs.setString(NICKNAME, documents[0][NICKNAME]);
        await prefs.setString(PHOTO_URL, documents[0][PHOTO_URL]);
        await prefs.setString(ABOUT_ME, documents[0][ABOUT_ME] ?? '');
        await prefs.setString(PHONE, documents[0][PHONE]);
        unawaited(Navigator.pushReplacement(context,
            new MaterialPageRoute(builder: (context) => EnigmaWrapper())));
        Enigma.toast('Welcome back!');
      }
    } else {
      Enigma.toast("Failed to log in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: enigmaBlack,
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: new Stepper(
                controlsBuilder: (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  return Row();
                },
                onStepTapped: (int step) => setState(() => _currentStep = step),
                type: StepperType.vertical,
                currentStep: _currentStep,
                steps: <Step>[
                  new Step(
                    title: Text('Phone Code'),
                    content: Row(children: <Widget>[
                      CountryPicker(
                        onChanged: (Country country) {
                          setState(() {
                            _selected = country;
                            phoneCode = '+' + country.dialingCode;
                          });
                        },
                        selectedCountry: _selected,
                      ),
                      SizedBox(width: 16.0),
                      RaisedButton(
                          padding: const EdgeInsets.all(8.0),
                          textColor: Colors.white,
                          color: enigmaBlue,
                          onPressed: () {
                            setState(() {
                              _currentStep += 1;
                            });
                          },
                          child: Text('Next')),
                    ]),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 0
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  new Step(
                    title: Text('Personal Information'),
                    content: Column(
                      children: <Widget>[
                        TextField(
                          controller: _name,
                          keyboardType: TextInputType.text,
                          decoration:
                              InputDecoration(labelText: 'Display name'),
                        ),
                        TextField(
                          controller: _phoneNo,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              helperText: 'Enter only the numbers.',
                              prefixText: phoneCode + ' ',
                              labelText: 'Phone No.'),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: Row(children: <Widget>[
                            RaisedButton(
                                padding: const EdgeInsets.all(8.0),
                                textColor: Colors.white,
                                color: enigmaBlue,
                                onPressed: () {
                                  RegExp e164 =
                                      new RegExp(r'^\+[1-9]\d{1,14}$');
                                  if (_name.text.trim().isNotEmpty) {
                                    String _phone =
                                        _phoneNo.text.toString().trim();
                                    if (_phone.isNotEmpty &&
                                        e164.hasMatch(phoneCode + _phone)) {
                                      verifyPhoneNumber();
                                      setState(() {
                                        isLoading = true;
                                        _currentStep += 1;
                                      });
                                    } else {
                                      Enigma.toast(
                                          'Please enter a valid number.');
                                    }
                                  } else {
                                    Enigma.toast('Name cannot be empty!');
                                  }
                                },
                                child: Text('Next')),
                            SizedBox(width: 8.0),
                            RaisedButton(
                                padding: const EdgeInsets.all(8.0),
                                textColor: Colors.black,
                                color: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    _currentStep -= 1;
                                  });
                                },
                                child: Text('Back')),
                          ]),
                        )
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 1
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  new Step(
                    title: Text('Verify OTP'),
                    content: Column(children: <Widget>[
                      TextField(
                        maxLength: 6,
                        controller: _smsCode,
                        decoration: InputDecoration(labelText: 'OTP Code'),
                        keyboardType: TextInputType.number,
                      ),
                      FlatButton(
                        padding: EdgeInsets.zero,
                        child: Text.rich(TextSpan(
                            text: 'By clicking Next, you are accepting our ',
                            children: [
                              TextSpan(
                                  text: 'Privacy Policy.',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline))
                            ])),
                        onPressed: () {
                          launch(PRIVACY_POLICY_URL);
                        },
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: Row(children: <Widget>[
                            RaisedButton(
                                padding: const EdgeInsets.all(8.0),
                                textColor: Colors.white,
                                color: enigmaBlue,
                                onPressed: () {
                                  if (_smsCode.text.length == 6) {
                                    handleSignIn();
                                  } else
                                    Enigma.toast(
                                        'Please enter the correct OTP Code');
                                },
                                child: Text('Next')),
                            SizedBox(width: 8.0),
                            RaisedButton(
                                padding: const EdgeInsets.all(8.0),
                                textColor: Colors.black,
                                color: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    _currentStep -= 1;
                                  });
                                },
                                child: Text('Back')),
                          ]))
                    ]),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 2
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                ],
              ),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(enigmaBlue),
                        ),
                      ),
                      color: enigmaBlack.withOpacity(0.8),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
      data: EnigmaTheme,
    );
  }
}
