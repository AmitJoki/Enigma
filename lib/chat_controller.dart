import 'dart:core';
import 'dart:async';
import 'package:Enigma/DataModel.dart';
import 'package:Enigma/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Enigma/const.dart';
import 'package:flutter/material.dart';
import 'package:Enigma/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController {
  static request(currentUserNo, peerNo) {
    Firestore.instance
        .collection(USERS)
        .document(currentUserNo)
        .collection(CHATS_WITH)
        .document(CHATS_WITH)
        .setData({'$peerNo': ChatStatus.waiting.index}, merge: true);
    Firestore.instance
        .collection(USERS)
        .document(peerNo)
        .collection(CHATS_WITH)
        .document(CHATS_WITH)
        .setData({'$currentUserNo': ChatStatus.requested.index}, merge: true);
  }

  static accept(currentUserNo, peerNo) {
    Firestore.instance
        .collection(USERS)
        .document(currentUserNo)
        .collection(CHATS_WITH)
        .document(CHATS_WITH)
        .setData({'$peerNo': ChatStatus.accepted.index}, merge: true);
  }

  static block(currentUserNo, peerNo) {
    Firestore.instance
        .collection(USERS)
        .document(currentUserNo)
        .collection(CHATS_WITH)
        .document(CHATS_WITH)
        .setData({'$peerNo': ChatStatus.blocked.index}, merge: true);
    Firestore.instance
        .collection(MESSAGES)
        .document(Enigma.getChatId(currentUserNo, peerNo))
        .setData({'$currentUserNo': DateTime.now().millisecondsSinceEpoch},
            merge: true);
    Enigma.toast('Blocked.');
  }

  static Future<ChatStatus> getStatus(currentUserNo, peerNo) async {
    var doc = await Firestore.instance
        .collection(USERS)
        .document(currentUserNo)
        .collection(CHATS_WITH)
        .document(CHATS_WITH)
        .get();
    return ChatStatus.values[doc[peerNo]];
  }

  static hideChat(currentUserNo, peerNo) {
    Firestore.instance.collection(USERS).document(currentUserNo).setData({
      HIDDEN: FieldValue.arrayUnion([peerNo])
    }, merge: true);
    Enigma.toast('Chat hidden.');
  }

  static unhideChat(currentUserNo, peerNo) {
    Firestore.instance.collection(USERS).document(currentUserNo).setData({
      HIDDEN: FieldValue.arrayRemove([peerNo])
    }, merge: true);
    Enigma.toast('Chat is visible.');
  }

  static lockChat(currentUserNo, peerNo) {
    Firestore.instance.collection(USERS).document(currentUserNo).setData({
      LOCKED: FieldValue.arrayUnion([peerNo])
    }, merge: true);
    Enigma.toast('Chat locked.');
  }

  static unlockChat(currentUserNo, peerNo) {
    Firestore.instance.collection(USERS).document(currentUserNo).setData({
      LOCKED: FieldValue.arrayRemove([peerNo])
    }, merge: true);
    Enigma.toast('Chat unlocked.');
  }

  static void authenticate(DataModel model, String caption,
      {@required NavigatorState state,
      AuthenticationType type = AuthenticationType.passcode,
      @required SharedPreferences prefs,
      @required Function onSuccess,
      @required bool shouldPop}) {
    Map<String, dynamic> user = model.currentUser;
    if (user != null && model != null) {
      state.push(MaterialPageRoute<bool>(
          builder: (context) => Authenticate(
              shouldPop: shouldPop,
              caption: caption,
              type: type,
              model: model,
              state: state,
              answer: user[ANSWER],
              passcode: user[PASSCODE],
              question: user[QUESTION],
              phoneNo: user[PHONE],
              prefs: prefs,
              onSuccess: onSuccess)));
    }
  }
}
