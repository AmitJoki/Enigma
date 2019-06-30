import 'dart:async';
import 'dart:core';
import 'package:Enigma/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Enigma/chat.dart';
import 'package:Enigma/const.dart';
import 'package:Enigma/login.dart';
import 'package:Enigma/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Enigma/contacts.dart';
import 'package:Enigma/utils.dart';
import 'package:Enigma/DataModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:launch_review/launch_review.dart';
import 'package:local_auth/local_auth.dart';
import 'package:Enigma/alias.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (Enigma.isInDebugMode) {
      // In development mode, simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode, report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned<Future<void>>(() async {
    runApp(EnigmaWrapper());
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `_reportError` function. This sends
    // Dart errors to the dev console or Sentry depending on the environment.
    await Enigma.reportError(error, stackTrace);
  });
}

class EnigmaWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
                home:
                    MainScreen(currentUserNo: snapshot.data.getString(PHONE)));
          }
          return MaterialApp(
              home: Container(
            child: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(enigmaBlue)),
            ),
            color: enigmaBlack.withOpacity(0.8),
          ));
        });
  }
}

class MainScreen extends StatefulWidget {
  MainScreen({@required this.currentUserNo, key}) : super(key: key);
  final String currentUserNo;
  @override
  State createState() => new MainScreenState(currentUserNo: this.currentUserNo);
}

class MainScreenState extends State<MainScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  MainScreenState({Key key, this.currentUserNo}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }

  @override
  bool get wantKeepAlive => true;

  FirebaseMessaging notifications = new FirebaseMessaging();

  SharedPreferences prefs;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();
  }

  void setIsActive() async {
    if (currentUserNo != null)
      await Firestore.instance
          .collection(USERS)
          .document(currentUserNo)
          .setData({LAST_SEEN: true}, merge: true);
  }

  void setLastSeen() async {
    if (currentUserNo != null)
      await Firestore.instance
          .collection(USERS)
          .document(currentUserNo)
          .setData({LAST_SEEN: DateTime.now().millisecondsSinceEpoch},
              merge: true);
  }

  final TextEditingController _filter = new TextEditingController();
  bool isAuthenticating = false;

  StreamSubscription spokenSubscription;
  List<StreamSubscription> unreadSubscriptions = List<StreamSubscription>();

  List<StreamController> controllers = new List<StreamController>();

  @override
  void initState() {
    super.initState();
    Enigma.internetLookUp();
    WidgetsBinding.instance.addObserver(this);
    LocalAuthentication().canCheckBiometrics.then((res) {
      if (res) biometricEnabled = true;
    });
    getSignedInUserOrRedirect();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    controllers.forEach((controller) {
      controller.close();
    });
    _filter.dispose();
    spokenSubscription?.cancel();
    _userQuery.close();
    cancelUnreadSubscriptions();
    setLastSeen();
  }

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription?.cancel();
    });
  }

  DataModel _cachedModel;
  bool showHidden = false, biometricEnabled = false;
  getSignedInUserOrRedirect() async {
    prefs = await SharedPreferences.getInstance();
    if (currentUserNo == null || currentUserNo.isEmpty)
      unawaited(Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              builder: (context) =>
                  new LoginScreen(title: 'Sign in to Enigma'))));
    else {
      setIsActive();
      String fcmToken = await notifications.getToken();
      if (prefs.getBool(IS_TOKEN_GENERATED) != true) {
        await Firestore.instance
            .collection(USERS)
            .document(currentUserNo)
            .setData({
          NOTIFICATION_TOKENS: FieldValue.arrayUnion([fcmToken])
        }, merge: true);
        unawaited(prefs.setBool(IS_TOKEN_GENERATED, true));
      }
    }
  }

  String currentUserNo;

  bool isLoading = false;

  Widget buildItem(BuildContext context, Map<String, dynamic> user) {
    NavigatorState state = Navigator.of(context);
    if (user[PHONE] as String == currentUserNo) {
      return Container(width: 0, height: 0);
    } else {
      return StreamBuilder(
          stream: getUnread(user).asBroadcastStream(),
          builder: (context, AsyncSnapshot<MessageData> unreadData) {
            int unread = unreadData.hasData &&
                    unreadData.data.snapshot.documents.isNotEmpty
                ? unreadData.data.snapshot.documents
                    .where((t) => t[TIMESTAMP] > unreadData.data.lastSeen)
                    .length
                : 0;
            return Theme(
                data: ThemeData(
                    splashColor: enigmaBlue,
                    highlightColor: Colors.transparent),
                child: ListTile(
                    onLongPress: () {
                      ChatController.authenticate(_cachedModel,
                          'Authentication needed to unlock the chat.',
                          state: state,
                          shouldPop: true,
                          type: Enigma.getAuthenticationType(
                              biometricEnabled, _cachedModel),
                          prefs: prefs, onSuccess: () async {
                        await Future.delayed(Duration(seconds: 0));
                        unawaited(showDialog(
                            context: context,
                            builder: (context) {
                              return AliasForm(user, _cachedModel);
                            }));
                      });
                    },
                    leading: Enigma.avatar(user),
                    title: Text(
                      Enigma.getNickname(user),
                      style: TextStyle(color: enigmaWhite),
                    ),
                    onTap: () {
                      if (_cachedModel.currentUser[LOCKED] != null &&
                          _cachedModel.currentUser[LOCKED]
                              .contains(user[PHONE])) {
                        NavigatorState state = Navigator.of(context);
                        ChatController.authenticate(_cachedModel,
                            'Authentication needed to unlock the chat.',
                            state: state,
                            shouldPop: false,
                            type: Enigma.getAuthenticationType(
                                biometricEnabled, _cachedModel),
                            prefs: prefs, onSuccess: () {
                          state.pushReplacement(new MaterialPageRoute(
                              builder: (context) => new ChatScreen(
                                  unread: unread,
                                  model: _cachedModel,
                                  currentUserNo: currentUserNo,
                                  peerNo: user[PHONE] as String)));
                        });
                      } else {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new ChatScreen(
                                    unread: unread,
                                    model: _cachedModel,
                                    currentUserNo: currentUserNo,
                                    peerNo: user[PHONE] as String)));
                      }
                    },
                    trailing: Container(
                      child: unread != 0
                          ? Text(unread.toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                          : Container(width: 0, height: 0),
                      padding: const EdgeInsets.all(7.0),
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: user[LAST_SEEN] == true
                            ? Colors.green
                            : Colors.grey,
                      ),
                    )));
          });
    }
  }

  Stream<MessageData> getUnread(Map<String, dynamic> user) {
    String chatId = Enigma.getChatId(currentUserNo, user[PHONE]);
    var controller = StreamController<MessageData>.broadcast();
    unreadSubscriptions.add(Firestore.instance
        .collection(MESSAGES)
        .document(chatId)
        .snapshots()
        .listen((doc) {
      if (doc[currentUserNo] != null && doc[currentUserNo] is int) {
        unreadSubscriptions.add(Firestore.instance
            .collection(MESSAGES)
            .document(chatId)
            .collection(chatId)
            .snapshots()
            .listen((snapshot) {
          controller.add(
              MessageData(snapshot: snapshot, lastSeen: doc[currentUserNo]));
        }));
      }
    }));
    controllers.add(controller);
    return controller.stream;
  }

  _isHidden(phoneNo) {
    Map<String, dynamic> _currentUser = _cachedModel.currentUser;
    return _currentUser[HIDDEN] != null &&
        _currentUser[HIDDEN].contains(phoneNo);
  }

  StreamController<String> _userQuery =
      new StreamController<String>.broadcast();

  List<Map<String, dynamic>> _users = List<Map<String, dynamic>>();

  _chats(Map<String, Map<String, dynamic>> _userData,
      Map<String, dynamic> currentUser) {
    _users = Map.from(_userData)
        .values
        .where((_user) => _user.keys.contains(CHAT_STATUS))
        .toList()
        .cast<Map<String, dynamic>>();
    Map<String, int> _lastSpokenAt = _cachedModel.lastSpokenAt;
    List<Map<String, dynamic>> filtered = List<Map<String, dynamic>>();

    _users.sort((a, b) {
      int aTimestamp = _lastSpokenAt[a[PHONE]] ?? 0;
      int bTimestamp = _lastSpokenAt[b[PHONE]] ?? 0;
      return bTimestamp - aTimestamp;
    });

    if (!showHidden) {
      _users.removeWhere((_user) => _isHidden(_user[PHONE]));
    }

    return Stack(
      children: <Widget>[
        RefreshIndicator(
            onRefresh: () {
              if (showHidden == false && _userData.length != _users.length) {
                isAuthenticating = true;
                ChatController.authenticate(_cachedModel,
                    'Authentication needed to show the hidden chats.',
                    shouldPop: true,
                    type: Enigma.getAuthenticationType(
                        biometricEnabled, _cachedModel),
                    state: Navigator.of(context),
                    prefs: prefs, onSuccess: () {
                  isAuthenticating = false;
                  setState(() {
                    showHidden = true;
                  });
                });
              } else {
                if (showHidden != false)
                  setState(() {
                    showHidden = false;
                  });
                return Future.value(false);
              }
              return Future.value(false);
            },
            child: Container(
                child: _users.isNotEmpty
                    ? StreamBuilder(
                        stream: _userQuery.stream.asBroadcastStream(),
                        builder: (context, snapshot) {
                          if (_filter.text.isNotEmpty ||
                              snapshot.hasData && snapshot.data.isNotEmpty) {
                            filtered = this._users.where((user) {
                              return user[NICKNAME]
                                  .toLowerCase()
                                  .trim()
                                  .contains(new RegExp(r'' +
                                      _filter.text.toLowerCase().trim() +
                                      ''));
                            }).toList();
                            if (filtered.isNotEmpty)
                              return ListView.builder(
                                padding: EdgeInsets.all(10.0),
                                itemBuilder: (context, index) => buildItem(
                                    context, filtered.elementAt(index)),
                                itemCount: filtered.length,
                              );
                            else
                              return ListView(children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height /
                                                3.5),
                                    child: Center(
                                      child: Text('No search results.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: enigmaWhite,
                                          )),
                                    ))
                              ]);
                          }
                          return ListView.builder(
                            padding: EdgeInsets.all(10.0),
                            itemBuilder: (context, index) =>
                                buildItem(context, _users.elementAt(index)),
                            itemCount: _users.length,
                          );
                        })
                    : ListView(children: [
                        Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 3.5),
                            child: Center(
                              child: Padding(
                                  padding: EdgeInsets.all(30.0),
                                  child: Text(
                                      'Start conversing by pressing the button at bottom right!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: enigmaWhite,
                                      ))),
                            ))
                      ]))),
      ],
    );
  }

  DataModel getModel() {
    _cachedModel ??= DataModel(currentUserNo);
    return _cachedModel;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Enigma.getNTPWrappedWidget(WillPopScope(
        onWillPop: () {
          if (!isAuthenticating) setLastSeen();
          return Future.value(true);
        },
        child: ScopedModel<DataModel>(
          model: getModel(),
          child: ScopedModelDescendant<DataModel>(
              builder: (context, child, _model) {
            _cachedModel = _model;
            return Scaffold(
                backgroundColor: enigmaBlack,
                floatingActionButton: _model.loaded
                    ? FloatingActionButton(
                        child: Icon(
                          Icons.chat,
                          size: 30.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new Contacts(
                                      prefs: prefs,
                                      biometricEnabled: biometricEnabled,
                                      currentUserNo: currentUserNo,
                                      model: _cachedModel)));
                        })
                    : Container(),
                appBar: AppBar(
                    bottom: PreferredSize(
                        preferredSize: Size.fromHeight(40.0),
                        child: TextField(
                          autofocus: false,
                          style: TextStyle(color: enigmaWhite),
                          controller: _filter,
                          decoration: new InputDecoration(
                              focusedBorder: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              hintText: 'Search ',
                              hintStyle: TextStyle(color: Colors.grey)),
                        )),
                    backgroundColor: enigmaBlack,
                    title: Text(
                      'Enigma',
                      style: TextStyle(
                          color: enigmaWhite, fontWeight: FontWeight.bold),
                    ),
                    centerTitle: false,
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.sentiment_satisfied),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Theme(
                                  data: EnigmaTheme,
                                  child: SimpleDialog(children: <Widget>[
                                    ListTile(
                                        contentPadding:
                                            EdgeInsets.only(top: 20),
                                        subtitle: Padding(
                                            child: Text(
                                              'Enjoying using Enigma? Rate us!',
                                              textAlign: TextAlign.center,
                                            ),
                                            padding:
                                                EdgeInsets.only(top: 10.0)),
                                        title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.star, size: 40),
                                              Icon(Icons.star, size: 40),
                                              Icon(Icons.star, size: 40),
                                              Icon(Icons.star, size: 40),
                                              Icon(Icons.star, size: 40),
                                            ]),
                                        onTap: () {
                                          LaunchReview.launch();
                                          Navigator.pop(context);
                                        }),
                                    Divider(),
                                    Padding(
                                        child: Text(
                                          'Suggestions? Feedback? Or just want to say hello?',
                                          style: TextStyle(
                                              fontSize: 14, color: enigmaWhite),
                                          textAlign: TextAlign.justify,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10)),
                                    Center(
                                        child: RaisedButton.icon(
                                            icon: Icon(Icons.email),
                                            label: Text('Send an email!'),
                                            onPressed: () {
                                              launch(
                                                  'mailto:amitjoki@gmail.com?subject=Enigma%20Feedback');
                                              Navigator.pop(context);
                                            }))
                                  ]),
                                );
                              });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {
                          Enigma.invite();
                        },
                      ),
                      IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Theme(
                                      child: SimpleDialog(
                                        contentPadding: EdgeInsets.all(20),
                                        children: <Widget>[
                                          ListTile(
                                              title: Text(
                                                  'Swipe down the screen to view hidden chats.'),
                                              subtitle: Text(
                                                  'Swipe down again to hide them')),
                                          ListTile(
                                              title: Text(
                                                  'Long press on the chat to set alias.'))
                                        ],
                                      ),
                                      data: EnigmaTheme);
                                });
                          }),
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          ChatController.authenticate(_cachedModel,
                              'Authentication needed to unlock the Settings',
                              state: Navigator.of(context),
                              shouldPop: false,
                              type: Enigma.getAuthenticationType(
                                  biometricEnabled, _cachedModel),
                              prefs: prefs, onSuccess: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Settings(
                                          biometricEnabled: biometricEnabled,
                                          type: Enigma.getAuthenticationType(
                                              biometricEnabled, _cachedModel),
                                        )));
                          });
                        },
                      )
                    ]),
                body: _chats(_model.userData, _model.currentUser));
          }),
        )));
  }
}

class MessageData {
  int lastSeen;
  QuerySnapshot snapshot;
  MessageData({@required this.snapshot, @required this.lastSeen});
}
