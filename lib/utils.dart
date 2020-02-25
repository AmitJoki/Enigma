import 'dart:async';
import 'dart:io';

import 'package:Enigma/DataModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Enigma/const.dart';
import 'package:crypto/crypto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ntp/ntp.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry/sentry.dart';
import 'dart:convert';

import 'package:share/share.dart';

class Enigma {
  static final SentryClient _sentry = SentryClient(
      dsn: "ENTER YOUR SENTRY DSN HERE");

  static bool get isInDebugMode {
    // Assume you're in production mode
    bool inDebugMode = false;

    // Assert expressions are only evaluated during development. They are ignored
    // in production. Therefore, this code only sets `inDebugMode` to true
    // in a development environment.
    assert(inDebugMode = true);

    return inDebugMode;
  }

  static Future<void> reportError(dynamic error, dynamic stackTrace) async {
    // Print the exception to the console
    print('Caught error: $error');
    if (isInDebugMode) {
      // Print the full stacktrace in debug mode
      print(stackTrace);
      return;
    } else {
      // Send the Exception and Stacktrace to Sentry in Production mode
      await _sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }

  static String getNickname(Map<String, dynamic> user) =>
      user[ALIAS_NAME] ?? user[NICKNAME];

  static void toast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: enigmaBlack.withOpacity(0.95),
        textColor: enigmaWhite);
  }

  static void internetLookUp() {
    try {
      InternetAddress.lookup('example.com').catchError((e) {
        Enigma.toast('No internet connection.');
      });
    } catch (_) {
      Enigma.toast('No internet connection.');
    }
  }

  static void invite() {
    Share.share(
        'Let\'s chat on Enigma, join me at - https://play.google.com/store/apps/details?id=com.enigma.amitjoki');
  }

  static Widget avatar(Map<String, dynamic> user,
      {File image, double radius = 22.5}) {
    if (image == null) {
      if (user[ALIAS_AVATAR] == null)
        return (user[PHOTO_URL] ?? '').isNotEmpty
            ? CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user[PHOTO_URL]),
                radius: radius)
            : CircleAvatar(
                backgroundColor: enigmaBlue,
                foregroundColor: Colors.white,
                child: Text(getInitials(Enigma.getNickname(user))),
                radius: radius,
              );
      return CircleAvatar(
        backgroundImage: Image.file(File(user[ALIAS_AVATAR])).image,
        radius: radius,
      );
    }
    return CircleAvatar(
        backgroundImage: Image.file(image).image, radius: radius);
  }

  static Future<int> getNTPOffset() {
    return NTP.getNtpOffset();
  }

  static Widget getNTPWrappedWidget(Widget child) {
    return FutureBuilder(
        future: NTP.getNtpOffset(),
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            if (snapshot.data > Duration(minutes: 1).inMilliseconds ||
                snapshot.data < -Duration(minutes: 1).inMilliseconds)
              return Material(
                  color: enigmaBlack,
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            "Your clock time is out of sync with the server time. Please set it right to continue.",
                            style: TextStyle(color: enigmaWhite, fontSize: 18),
                          ))));
          }
          return child;
        });
  }

  static void showRationale(rationale) async {
    Enigma.toast(rationale);
    await Future.delayed(Duration(seconds: 2));
    Enigma.toast(
        'If you change your mind, you can grant the permission through App Settings > Permissions');
  }

  static Future<bool> checkAndRequestPermission(PermissionGroup permission) {
    Completer<bool> completer = new Completer<bool>();
    PermissionHandler().checkPermissionStatus(permission).then((status) {
      if (status != PermissionStatus.granted) {
        PermissionHandler().requestPermissions([permission]).then((_status) {
          bool granted = _status.values.first == PermissionStatus.granted;
          completer.complete(granted);
        });
      } else
        completer.complete(true);
    });
    return completer.future;
  }

  static String getInitials(String name) {
    try {
      List<String> names = name
          .trim()
          .replaceAll(new RegExp(r'[\W]'), '')
          .toUpperCase()
          .split(' ');
      names.retainWhere((s) => s.trim().isNotEmpty);
      if (names.length >= 2)
        return names.elementAt(0)[0] + names.elementAt(1)[0];
      else if (names.elementAt(0).length >= 2)
        return names.elementAt(0).substring(0, 2);
      else
        return names.elementAt(0)[0];
    } catch (e) {
      return '?';
    }
  }

  static String getChatId(String currentUserNo, String peerNo) {
    if (currentUserNo.hashCode <= peerNo.hashCode)
      return '$currentUserNo-$peerNo';
    return '$peerNo-$currentUserNo';
  }

  static AuthenticationType getAuthenticationType(
      bool biometricEnabled, DataModel model) {
    if (biometricEnabled && model?.currentUser != null) {
      return AuthenticationType.values[model.currentUser[AUTHENTICATION_TYPE]];
    }
    return AuthenticationType.passcode;
  }

  static ChatStatus getChatStatus(int index) => ChatStatus.values[index];

  static String normalizePhone(String phone) =>
      phone.replaceAll(new RegExp(r"\s+\b|\b\s"), "");

  static String getHashedAnswer(String answer) {
    answer = answer.toLowerCase().replaceAll(new RegExp(r"[^a-z0-9]"), "");
    var bytes = utf8.encode(answer); // data being hashed
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }

  static String getHashedString(String str) {
    var bytes = utf8.encode(str); // data being hashed
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }
}
