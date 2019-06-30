import 'dart:async';
import 'dart:io';

import 'package:Enigma/PassCode/passcode_screen.dart';
import 'package:Enigma/security.dart';
import 'package:Enigma/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Enigma/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Enigma/ImagePicker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  final bool biometricEnabled;
  final AuthenticationType type;
  Settings({this.biometricEnabled, this.type});
  @override
  State createState() => new SettingsState();
}

class SettingsState extends State<Settings> {
  TextEditingController controllerNickname;
  TextEditingController controllerAboutMe;

  SharedPreferences prefs;

  String phone = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();
  AuthenticationType _type;

  @override
  void initState() {
    super.initState();
    Enigma.internetLookUp();
    readLocal();
    _type = widget.type;
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    phone = prefs.getString(PHONE) ?? '';
    nickname = prefs.getString(NICKNAME) ?? '';
    aboutMe = prefs.getString(ABOUT_ME) ?? '';
    photoUrl = prefs.getString(PHOTO_URL) ?? '';

    controllerNickname = new TextEditingController(text: nickname);
    controllerAboutMe = new TextEditingController(text: aboutMe);

    // Force refresh input
    setState(() {});
  }

  Future getImage(File image) async {
    if (image != null) {
      setState(() {
        avatarImageFile = image;
      });
    }
    return uploadFile();
  }

  Future uploadFile() async {
    String fileName = phone;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageTaskSnapshot uploading =
        await reference.putFile(avatarImageFile).onComplete;
    return uploading.ref.getDownloadURL();
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });
    nickname =
        controllerNickname.text.isEmpty ? nickname : controllerNickname.text;
    aboutMe = controllerAboutMe.text.isEmpty ? aboutMe : controllerAboutMe.text;
    Firestore.instance.collection(USERS).document(phone).updateData({
      NICKNAME: nickname,
      ABOUT_ME: aboutMe,
      AUTHENTICATION_TYPE: _type.index,
    }).then((data) async {
      await prefs.setString(NICKNAME, nickname);
      await prefs.setString(ABOUT_ME, aboutMe);
      setState(() {
        isLoading = false;
      });
      Enigma.toast("Saved!");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Enigma.toast(err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Enigma.getNTPWrappedWidget(Theme(
        data: EnigmaTheme,
        child: Scaffold(
            appBar: new AppBar(
              title: new Text(
                'Settings',
              ),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.blue,
                  onPressed: handleUpdateData,
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      // Avatar
                      Container(
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              (avatarImageFile == null)
                                  ? (photoUrl != ''
                                      ? Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                                    child: Padding(
                                                        padding: EdgeInsets.all(
                                                            50.0),
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  enigmaBlue),
                                                        )),
                                                    width: 150.0,
                                                    height: 150.0),
                                            imageUrl: photoUrl,
                                            width: 150.0,
                                            height: 150.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(75.0)),
                                          clipBehavior: Clip.hardEdge,
                                        )
                                      : Icon(
                                          Icons.account_circle,
                                          size: 150.0,
                                          color: Colors.grey,
                                        ))
                                  : Material(
                                      child: Image.file(
                                        avatarImageFile,
                                        width: 150.0,
                                        height: 150.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(75.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: FloatingActionButton(
                                      child: Icon(Icons.camera_alt),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HybridImagePicker(
                                                        title: 'Pick an image',
                                                        callback: getImage,
                                                        profile: true))).then(
                                            (url) {
                                          if (url != null) {
                                            photoUrl = url.toString();
                                            Firestore.instance
                                                .collection(USERS)
                                                .document(phone)
                                                .updateData({
                                              PHOTO_URL: photoUrl
                                            }).then((data) async {
                                              await prefs.setString(
                                                  PHOTO_URL, photoUrl);
                                              setState(() {
                                                isLoading = false;
                                              });
                                              Enigma.toast(
                                                  "Profile Picture Changed!");
                                            }).catchError((err) {
                                              setState(() {
                                                isLoading = false;
                                              });

                                              Enigma.toast(err.toString());
                                            });
                                          }
                                        });
                                      })),
                            ],
                          ),
                        ),
                        width: double.infinity,
                        margin: EdgeInsets.all(20.0),
                      ),
                      ListTile(
                          title: TextFormField(
                        autovalidate: true,
                        controller: controllerNickname,
                        validator: (v) {
                          return v.isEmpty ? 'Name cannot be empty!' : null;
                        },
                        decoration: InputDecoration(labelText: 'Display Name'),
                      )),
                      ListTile(
                          title: TextFormField(
                        controller: controllerAboutMe,
                        decoration: InputDecoration(labelText: 'Status'),
                      )),
                      widget.biometricEnabled
                          ? Divider()
                          : Container(width: 0, height: 0),
                      widget.biometricEnabled
                          ? ListTile(
                              title: Text('Authentication Type'),
                              subtitle: Row(children: [
                                Radio(
                                    groupValue: _type,
                                    value: AuthenticationType.passcode,
                                    activeColor: Colors.blue,
                                    onChanged: (val) {
                                      setState(() {
                                        _type = val;
                                      });
                                    }),
                                Text('Passcode'),
                                Radio(
                                    groupValue: _type,
                                    value: AuthenticationType.biometric,
                                    activeColor: Colors.blue,
                                    onChanged: (val) {
                                      setState(() {
                                        _type = val;
                                      });
                                    }),
                                Text('Fingerprint')
                              ]),
                            )
                          : Container(width: 0, height: 0),
                      widget.biometricEnabled
                          ? Divider()
                          : Container(width: 0, height: 0),
                      ListTile(
                          title: Row(children: [
                        Expanded(
                            child: RaisedButton.icon(
                                icon: Icon(Icons.lock),
                                label: Text('Change Passcode'),
                                onPressed: _showLockScreen))
                      ])),
                      ListTile(
                          title: Row(children: [
                        Expanded(
                            child: RaisedButton.icon(
                                icon: Icon(Icons.security),
                                label: Text('Change Security Question'),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Security(phone, shouldPop: true, onSuccess: () {
                                                Navigator.pop(context);
                                              }, setPasscode: false)));
                                }))
                      ])),
                      ListTile(
                          title: FlatButton(
                        child: Text('Privacy Policy',
                            style: TextStyle(
                                decoration: TextDecoration.underline)),
                        onPressed: () {
                          launch(PRIVACY_POLICY_URL);
                        },
                      ))
                    ],
                  ),
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                ),
                // Loading
                Positioned(
                  child: isLoading
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(enigmaBlue)),
                          ),
                          color: Colors.black.withOpacity(0.8),
                        )
                      : Container(),
                ),
              ],
            ))));
  }

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = enteredPasscode.length == 4;
    _verificationNotifier.add(isValid);
  }

  _onSubmit(String newPasscode) {
    setState(() {
      isLoading = true;
    });
    Firestore.instance
        .collection(USERS)
        .document(phone)
        .updateData({PASSCODE: Enigma.getHashedString(newPasscode)}).then((_) {
      prefs.setInt(ANSWER_TRIES, 0);
      prefs.setInt(PASSCODE_TRIES, 0);
      setState(() {
        isLoading = false;
        Enigma.toast('Updated!');
      });
    });
  }

  _showLockScreen() {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
                onSubmit: _onSubmit,
                wait: true,
                passwordDigits: 4,
                title: 'Enter the passcode',
                passwordEnteredCallback: _onPasscodeEntered,
                cancelLocalizedText: 'Cancel',
                deleteLocalizedText: 'Delete',
                shouldTriggerVerification: _verificationNotifier.stream,
              ),
        ));
  }
}
