import 'package:Enigma/chat_controller.dart';
import 'package:Enigma/open_settings.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:Enigma/const.dart';
import 'dart:async';
import 'package:Enigma/utils.dart';
import 'package:Enigma/pre_chat.dart';
import 'package:Enigma/chat.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:Enigma/DataModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contacts extends StatefulWidget {
  const Contacts({
    @required this.currentUserNo,
    @required this.model,
    @required this.biometricEnabled,
    @required this.prefs,
  });
  final String currentUserNo;
  final DataModel model;
  final SharedPreferences prefs;
  final bool biometricEnabled;

  @override
  _ContactsState createState() => new _ContactsState();
}

class _ContactsState extends State<Contacts>
  with AutomaticKeepAliveClientMixin  {
  Map<String, String> contacts;
  Map<String, String> _filtered = new Map<String, String>();

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = new TextEditingController();

  String _query;

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  _ContactsState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _query = "";
          this._filtered = this.contacts;
        });
      } else {
        setState(() {
          _query = _filter.text;
          this._filtered =
              Map.fromEntries(this.contacts.entries.where((MapEntry contact) {
            return contact.value
                .toLowerCase()
                .trim()
                .contains(new RegExp(r'' + _query.toLowerCase().trim() + ''));
          }));
        });
      }
    });
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(enigmaBlue),
        )),
      )
    ]);
  }

  @override
  initState() {
    super.initState();
    getContacts();
  }

  String getNormalizedNumber(String number) {
    if (number == null) return null;
    return number.replaceAll(new RegExp('[^0-9+]'), '');
  }

  _isHidden(String phoneNo) {
    Map<String, dynamic> _currentUser = widget.model.currentUser;
    return _currentUser[HIDDEN] != null &&
        _currentUser[HIDDEN].contains(phoneNo);
  }

  Future<Map<String, String>> getContacts({bool refresh = false}) {
    Completer<Map<String, String>> completer =
        new Completer<Map<String, String>>();

    LocalStorage storage = LocalStorage(CACHED_CONTACTS);

    Map<String, String> _cachedContacts;

    completer.future.then((c) {
      c.removeWhere((key, val) => _isHidden(key));
      if (mounted) {
        setState(() {
          this.contacts = this._filtered = c;
        });
      }
    });

    Enigma.checkAndRequestPermission(PermissionGroup.contacts).then((res) {
      if (res) {
        storage.ready.then((ready) {
          if (ready) {
            var _stored = storage.getItem(CACHED_CONTACTS);
            if (_stored == null)
              _cachedContacts = new Map<String, String>();
            else
              _cachedContacts = Map.from(_stored);

            if (refresh == false && _cachedContacts.isNotEmpty)
              completer.complete(_cachedContacts);
            else {
              String getNormalizedNumber(String number) {
                if (number == null) return null;
                return number.replaceAll(new RegExp('[^0-9+]'), '');
              }

              ContactsService.getContacts(withThumbnails: false)
                  .then((Iterable<Contact> contacts) {
                contacts.where((c) => c.phones.isNotEmpty).forEach((Contact p) {
                  if (p?.displayName != null && p.phones.isNotEmpty) {
                    List<String> numbers = p.phones
                        .map((number) {
                          String _phone = getNormalizedNumber(number.value);
                          if (!_phone.startsWith('+')) {
                            // If the country code is not available,
                            // the most probable country code
                            // will be that of current user.
                            String cc = widget.model.currentUser[COUNTRY_CODE]
                                .toString()
                                .substring(1);
                            String trunk;
                            trunk = CountryCode_TrunkCode.firstWhere(
                                (list) => list.first == cc)?.toList()?.last;
                            if (trunk == null || trunk.isEmpty) trunk = '-';
                            if (_phone.startsWith(trunk)) {
                              _phone = _phone.replaceFirst(RegExp(trunk), '');
                            }
                            _phone = '+$cc$_phone';
                            return _phone;
                          }
                          return _phone;
                        })
                        .toList()
                        .where((s) => s != null)
                        .toList();
                    numbers.forEach((number) {
                      _cachedContacts[number] = p.displayName;
                    });
                  }
                });
                storage.setItem(CACHED_CONTACTS, _cachedContacts);
                completer.complete(_cachedContacts);
              });
            }
          }
        });
      } else {
        Enigma.showRationale(
            'Permission to access contacts is needed to connect with people you know.');
        Navigator.pushReplacement(context,
            new MaterialPageRoute(builder: (context) => OpenSettings()));
      }
    });

    return completer.future;
  }

  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Search Contacts');

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          autofocus: true,
          style: TextStyle(color: enigmaWhite),
          controller: _filter,
          decoration: new InputDecoration(
              hintText: 'Search ', hintStyle: TextStyle(color: enigmaWhite)),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Search Contacts');

        _filter.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Enigma.getNTPWrappedWidget(ScopedModel<DataModel>(
        model: widget.model,
        child: ScopedModelDescendant<DataModel>(
            builder: (context, child, model) {
          return Scaffold(
              backgroundColor: enigmaBlack,
              appBar: AppBar(
                backgroundColor: enigmaBlack,
                centerTitle: false,
                title: _appBarTitle,
                actions: <Widget>[
                  IconButton(
                    icon: _searchIcon,
                    onPressed: _searchPressed,
                  )
                ],
              ),
              body: contacts == null
                  ? loading()
                  : RefreshIndicator(
                      onRefresh: () {
                        return getContacts(refresh: true);
                      },
                      child: _filtered.isEmpty
                          ? ListView(children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          2.5),
                                  child: Center(
                                    child: Text('No search results.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: enigmaWhite,
                                        )),
                                  ))
                            ])
                          : ListView.builder(
                              itemCount: _filtered.length,
                              itemBuilder: (context, idx) {
                                MapEntry user =
                                    _filtered.entries.elementAt(idx);
                                String phone = user.key;
                                return ListTile(
                                  leading: CircleAvatar(
                                      radius: 22.5,
                                      child:
                                          Text(Enigma.getInitials(user.value))),
                                  title: Text(user.value,
                                      style: TextStyle(color: enigmaWhite)),
                                  subtitle: Text(phone,
                                      style: TextStyle(color: Colors.grey)),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 0.0),
                                  onTap: () {
                                    dynamic wUser = model.userData[phone];
                                    if (wUser != null &&
                                        wUser[CHAT_STATUS] != null) {
                                      if (model.currentUser[LOCKED] != null &&
                                          model.currentUser[LOCKED]
                                              .contains(phone)) {
                                        ChatController.authenticate(model,
                                            'Authentication needed to unlock the chat.',
                                            prefs: widget.prefs,
                                            shouldPop: false,
                                            state: Navigator.of(context),
                                            type: Enigma.getAuthenticationType(
                                                widget.biometricEnabled, model),
                                            onSuccess: () {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      new ChatScreen(
                                                          model: model,
                                                          currentUserNo: widget
                                                              .currentUserNo,
                                                          peerNo: phone,
                                                          unread: 0)),
                                              (Route r) => r.isFirst);
                                        });
                                      } else {
                                        Navigator.pushReplacement(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    new ChatScreen(
                                                        model: model,
                                                        currentUserNo: widget
                                                            .currentUserNo,
                                                        peerNo: phone,
                                                        unread: 0)));
                                      }
                                    } else {
                                      Navigator.pushReplacement(context,
                                          new MaterialPageRoute(
                                              builder: (context) {
                                        return new PreChat(
                                            model: widget.model,
                                            name: user.value,
                                            phone: phone,
                                            currentUserNo:
                                                widget.currentUserNo);
                                      }));
                                    }
                                  },
                                );
                              },
                            )));
        })));
  }
}
