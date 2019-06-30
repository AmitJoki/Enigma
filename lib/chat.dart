import 'dart:async';
import 'dart:io';
import 'package:Enigma/GiphyPicker/giphy_picker.dart';
import 'package:Enigma/photo_view.dart';
import 'package:Enigma/profile_view.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Enigma/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Enigma/ImagePicker/image_picker.dart';
import 'package:Enigma/bubble.dart';
import 'package:Enigma/E2EE/e2ee.dart' as e2ee;
import 'package:Enigma/seen_provider.dart';
import 'package:Enigma/seen_state.dart';
import 'package:Enigma/message.dart';
import 'package:Enigma/utils.dart';
import 'package:Enigma/chat_controller.dart';
import 'package:Enigma/DataModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:Enigma/save.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Enigma/crc.dart';

class ChatScreen extends StatefulWidget {
  final String peerNo, currentUserNo;
  final DataModel model;
  final int unread;
  ChatScreen(
      {Key key,
      @required this.currentUserNo,
      @required this.peerNo,
      @required this.model,
      @required this.unread});

  @override
  State createState() =>
      new _ChatScreenState(currentUserNo: currentUserNo, peerNo: peerNo);
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  String peerAvatar, peerNo, currentUserNo, privateKey, sharedSecret;
  bool locked, hidden;
  Map<String, dynamic> peer, currentUser;
  int chatStatus, unread;

  _ChatScreenState({@required this.peerNo, @required this.currentUserNo});

  String chatId;
  SharedPreferences prefs;

  bool typing = false;

  File imageFile;
  bool isLoading;
  String imageUrl;
  SeenState seenState;
  List<Message> messages = new List<Message>();
  List<Map<String, dynamic>> _savedMessageDocs =
      new List<Map<String, dynamic>>();

  int uploadTimestamp;

  StreamSubscription seenSubscription, msgSubscription, deleteUptoSubscription;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController realtime = new ScrollController();
  final ScrollController saved = new ScrollController();
  DataModel _cachedModel;

  @override
  void initState() {
    super.initState();
    Enigma.internetLookUp();
    _cachedModel = widget.model;
    updateLocalUserData(_cachedModel);
    readLocal();
    seenState = new SeenState(false);
    WidgetsBinding.instance.addObserver(this);
    chatId = '';
    unread = widget.unread;
    isLoading = false;
    imageUrl = '';
    loadSavedMessages();
  }

  updateLocalUserData(model) {
    peer = model.userData[peerNo];
    currentUser = _cachedModel.currentUser;
    if (currentUser != null && peer != null) {
      hidden =
          currentUser[HIDDEN] != null && currentUser[HIDDEN].contains(peerNo);
      locked =
          currentUser[LOCKED] != null && currentUser[LOCKED].contains(peerNo);
      chatStatus = peer[CHAT_STATUS];
      peerAvatar = peer[PHOTO_URL];
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen();
    msgSubscription?.cancel();
    seenSubscription?.cancel();
    deleteUptoSubscription?.cancel();
  }

  void setLastSeen() async {
    if (chatStatus != ChatStatus.blocked.index) {
      if (chatId != null) {
        await Firestore.instance.collection(MESSAGES).document(chatId).setData(
            {'$currentUserNo': DateTime.now().millisecondsSinceEpoch},
            merge: true);
      }
    }
  }

  dynamic encryptWithCRC(String input) {
    try {
      String encrypted = cryptor.encrypt(input, iv: iv).base64;
      int crc = CRC32.compute(input);
      return '$encrypted$CRC_SEPARATOR$crc';
    } catch (e) {
      Enigma.toast('Waiting for your peer to join the chat.');
      return false;
    }
  }

  String decryptWithCRC(String input) {
    try {
      if (input.contains(CRC_SEPARATOR)) {
        int idx = input.lastIndexOf(CRC_SEPARATOR);
        String msgPart = input.substring(0, idx);
        String crcPart = input.substring(idx + 1);
        int crc = int.tryParse(crcPart);
        if (crc != null) {
          msgPart =
              cryptor.decrypt(encrypt.Encrypted.fromBase64(msgPart), iv: iv);
          if (CRC32.compute(msgPart) == crc) return msgPart;
        }
      }
    } on FormatException {
      return '';
    }
    return '';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();
  }

  void setIsActive() async {
    await Firestore.instance
        .collection(MESSAGES)
        .document(chatId)
        .setData({'$currentUserNo': true}, merge: true);
  }

  dynamic lastSeen;

  FlutterSecureStorage storage = new FlutterSecureStorage();
  encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    try {
      privateKey = await storage.read(key: PRIVATE_KEY);
      sharedSecret = (await e2ee.X25519().calculateSharedSecret(
              e2ee.Key.fromBase64(privateKey, false),
              e2ee.Key.fromBase64(peer[PUBLIC_KEY], true)))
          .toBase64();
      final key = encrypt.Key.fromBase64(sharedSecret);
      cryptor = new encrypt.Encrypter(encrypt.Salsa20(key));
    } catch (e) {
      sharedSecret = null;
    }
    try {
      seenState.value = prefs.getInt(getLastSeenKey());
    } catch (e) {
      seenState.value = false;
    }
    chatId = Enigma.getChatId(currentUserNo, peerNo);
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty && typing == false) {
        lastSeen = peerNo;
        Firestore.instance
            .collection(USERS)
            .document(currentUserNo)
            .setData({LAST_SEEN: peerNo}, merge: true);
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        lastSeen = true;
        Firestore.instance
            .collection(USERS)
            .document(currentUserNo)
            .setData({LAST_SEEN: true}, merge: true);
        typing = false;
      }
    });
    setIsActive();
    deleteUptoSubscription = Firestore.instance
        .collection(MESSAGES)
        .document(chatId)
        .snapshots()
        .listen((doc) {
      if (doc != null && mounted) {
        deleteMessagesUpto(doc.data[DELETE_UPTO]);
      }
    });
    seenSubscription = Firestore.instance
        .collection(MESSAGES)
        .document(chatId)
        .snapshots()
        .listen((doc) {
      if (doc != null && mounted) {
        seenState.value = doc[peerNo] ?? false;
        if (seenState.value is int) {
          prefs.setInt(getLastSeenKey(), seenState.value);
        }
      }
    });
    loadMessagesAndListen();
  }

  String getLastSeenKey() {
    return "$peerNo-$LAST_SEEN";
  }

  getImage(File image) {
    if (image != null) {
      setState(() {
        imageFile = image;
      });
    }
    return uploadFile();
  }

  getWallpaper(File image) {
    if (image != null) {
      _cachedModel.setWallpaper(peerNo, image);
    }
    return Future.value(false);
  }

  getImageFileName(id, timestamp) {
    return "$id-$timestamp";
  }

  Future uploadFile() async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = getImageFileName(currentUserNo, '$uploadTimestamp');
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageTaskSnapshot uploading =
        await reference.putFile(imageFile).onComplete;
    return uploading.ref.getDownloadURL();
  }

  void onSendMessage(String content, MessageType type, int timestamp) async {
    if (content.trim() != '') {
      content = content.trim();
      if (chatStatus == null) ChatController.request(currentUserNo, peerNo);
      textEditingController.clear();
      final encrypted = encryptWithCRC(content);
      if (encrypted is String) {
        Future messaging = Firestore.instance
            .collection(MESSAGES)
            .document(chatId)
            .collection(chatId)
            .document('$timestamp')
            .setData({
          FROM: currentUserNo,
          TO: peerNo,
          TIMESTAMP: timestamp,
          CONTENT: encrypted,
          TYPE: type.index
        });
        _cachedModel.addMessage(peerNo, timestamp, messaging);
        var tempDoc = {
          TIMESTAMP: timestamp,
          TYPE: type.index,
          CONTENT: content,
          FROM: currentUserNo,
        };
        setState(() {
          messages = List.from(messages)
            ..add(Message(
              buildTempMessage(type, content, timestamp, messaging),
              onTap: type == MessageType.image
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewWrapper(
                              tag: timestamp.toString(),
                              imageProvider:
                                  CachedNetworkImageProvider(content),
                            ),
                      ))
                  : null,
              onDismiss: null,
              onDoubleTap: () {
                save(tempDoc);
              },
              onLongPress: () {
                contextMenu(tempDoc);
              },
              from: currentUserNo,
              timestamp: timestamp,
            ));
        });

        unawaited(realtime.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut));
      } else {
        Enigma.toast('Nothing to send');
      }
    }
  }

  delete(int ts) {
    setState(() {
      messages.removeWhere((msg) => msg.timestamp == ts);
      messages = List.from(messages);
    });
  }

  contextMenu(Map<String, dynamic> doc, {bool saved = false}) {
    List<Widget> tiles = List<Widget>();
    if (saved == false) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.save_alt),
          title: Text(
            'Save',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            save(doc);
            Navigator.pop(context);
          }));
    }
    if (doc[FROM] == currentUserNo && saved == false) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.delete),
          title: Text(
            'Delete',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            delete(doc[TIMESTAMP]);
            Firestore.instance
                .collection(MESSAGES)
                .document(chatId)
                .collection(chatId)
                .document('${doc[TIMESTAMP]}')
                .delete();
            Navigator.pop(context);
            Enigma.toast('Deleted!');
          }));
    }
    if (saved == true) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.delete),
          title: Text(
            'Delete',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Save.deleteMessage(peerNo, doc);
            _savedMessageDocs
                .removeWhere((msg) => msg[TIMESTAMP] == doc[TIMESTAMP]);
            setState(() {
              _savedMessageDocs = List.from(_savedMessageDocs);
            });
            Navigator.pop(context);
            Enigma.toast('Deleted!');
          }));
    }
    if (doc[TYPE] == MessageType.text.index) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.content_copy),
          title: Text(
            'Copy',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: doc[CONTENT]));
            Navigator.pop(context);
            Enigma.toast('Copied!');
          }));
    }
    showDialog(
        context: context,
        builder: (context) {
          return Theme(data: EnigmaTheme, child: SimpleDialog(children: tiles));
        });
  }

  deleteUpto(int upto) {
    Firestore.instance
        .collection(MESSAGES)
        .document(chatId)
        .collection(chatId)
        .where(TIMESTAMP, isLessThanOrEqualTo: upto)
        .getDocuments()
        .then((query) {
      query.documents.forEach((msg) {
        if (msg[TYPE] == MessageType.image.index) {
          FirebaseStorage.instance
              .ref()
              .child(getImageFileName(msg[FROM], msg[TIMESTAMP]))
              .delete();
        }
        msg.reference.delete();
      });
    });

    Firestore.instance
        .collection(MESSAGES)
        .document(chatId)
        .setData({DELETE_UPTO: upto}, merge: true);
    deleteMessagesUpto(upto);
    empty = true;
  }

  deleteMessagesUpto(int upto) {
    if (upto != null) {
      int before = messages.length;
      setState(() {
        messages = List.from(messages.where((msg) => msg.timestamp > upto));
        if (messages.length < before) Enigma.toast('Conversation Ended!');
      });
    }
  }

  save(Map<String, dynamic> doc) async {
    Enigma.toast('Saved');
    if (!_savedMessageDocs.any((_doc) => _doc[TIMESTAMP] == doc[TIMESTAMP])) {
      String content;
      if (doc[TYPE] == MessageType.image.index) {
        content = doc[CONTENT].toString().startsWith('http')
            ? await Save.getBase64FromImage(imageUrl: doc[CONTENT] as String)
            : doc[CONTENT]; // if not a url, it is a base64 from saved messages
      } else {
        // If text
        content = doc[CONTENT];
      }
      doc[CONTENT] = content;
      Save.saveMessage(peerNo, doc);
      _savedMessageDocs.add(doc);
      setState(() {
        _savedMessageDocs = List.from(_savedMessageDocs);
      });
    }
  }

  Widget getTextMessage(bool isMe, Map<String, dynamic> doc, bool saved) {
    return Text(
      doc[CONTENT],
      style:
          TextStyle(color: isMe ? enigmaWhite : Colors.black, fontSize: 16.0),
    );
  }

  Widget getTempTextMessage(String message) {
    return Text(
      message,
      style: TextStyle(color: enigmaWhite, fontSize: 16.0),
    );
  }

  Widget getImageMessage(Map<String, dynamic> doc, {bool saved = false}) {
    return Container(
      child: saved
          ? Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: Save.getImageFromBase64(doc[CONTENT]).image,
                    fit: BoxFit.cover),
              ),
              width: 200.0,
              height: 200.0,
            )
          : CachedNetworkImage(
              placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(enigmaBlue),
                    ),
                    width: 200.0,
                    height: 200.0,
                    padding: EdgeInsets.all(80.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                  ),
              errorWidget: (context, str, error) => Material(
                    child: Image.asset(
                      'assets/img_not_available.jpeg',
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
              imageUrl: doc[CONTENT],
              width: 200.0,
              height: 200.0,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget getTempImageMessage({String url}) {
    return imageFile != null
        ? Container(
            child: Image.file(
              imageFile,
              width: 200.0,
              height: 200.0,
              fit: BoxFit.cover,
            ),
          )
        : getImageMessage({CONTENT: url});
  }

  Widget buildMessage(Map<String, dynamic> doc,
      {bool saved = false, List<Message> savedMsgs}) {
    final bool isMe = doc[FROM] == currentUserNo;
    bool isContinuing;
    if (savedMsgs == null)
      isContinuing =
          messages.isNotEmpty ? messages.last.from == doc[FROM] : false;
    else {
      isContinuing =
          savedMsgs.isNotEmpty ? savedMsgs.last.from == doc[FROM] : false;
    }
    return SeenProvider(
        timestamp: doc[TIMESTAMP].toString(),
        data: seenState,
        child: Bubble(
            child: doc[TYPE] == MessageType.text.index
                ? getTextMessage(isMe, doc, saved)
                : getImageMessage(
                    doc,
                    saved: saved,
                  ),
            isMe: isMe,
            timestamp: doc[TIMESTAMP],
            delivered: _cachedModel.getMessageStatus(peerNo, doc[TIMESTAMP]),
            isContinuing: isContinuing));
  }

  Widget buildTempMessage(MessageType type, content, timestamp, delivered) {
    final bool isMe = true;
    return SeenProvider(
        timestamp: timestamp.toString(),
        data: seenState,
        child: Bubble(
          child: type == MessageType.text
              ? getTempTextMessage(content)
              : getTempImageMessage(url: content),
          isMe: isMe,
          timestamp: timestamp,
          delivered: delivered,
          isContinuing:
              messages.isNotEmpty && messages.last.from == currentUserNo,
        ));
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(enigmaBlue)),
              ),
              color: enigmaBlack.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    if (chatStatus == ChatStatus.requested.index) {
      return AlertDialog(
        backgroundColor: Colors.black12,
        elevation: 10.0,
        title: Text(
          'Accept ${peer[NICKNAME]}\'s invitation?',
          style: TextStyle(color: enigmaWhite),
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Reject'),
              onPressed: () {
                ChatController.block(currentUserNo, peerNo);
                setState(() {
                  chatStatus = ChatStatus.blocked.index;
                });
              }),
          FlatButton(
              child: Text('Accept'),
              onPressed: () {
                ChatController.accept(currentUserNo, peerNo);
                setState(() {
                  chatStatus = ChatStatus.accepted.index;
                });
              })
        ],
      );
    }
    return Container(
      child: Row(
        children: <Widget>[
          IconButton(
              color: enigmaWhite,
              padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.gif, size: 40),
              onPressed: () async {
                final gif = await GiphyPicker.pickGif(
                    context: context,
                    apiKey: 'PkjPKUvd84HUEd2GGStxDxW8za02HBti');
                onSendMessage(gif.images.original.url, MessageType.image,
                    DateTime.now().millisecondsSinceEpoch);
              }),
          IconButton(
            icon: new Icon(Icons.image),
            padding: EdgeInsets.all(0.0),
            onPressed: chatStatus == ChatStatus.blocked.index
                ? null
                : () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HybridImagePicker(
                                  title: 'Pick an image',
                                  callback: getImage,
                                ))).then((url) {
                      if (url != null) {
                        onSendMessage(url, MessageType.image, uploadTimestamp);
                      }
                    });
                  },
            color: enigmaWhite,
          ),
          Flexible(
            child: Container(
              child: TextField(
                maxLines: null,
                style: TextStyle(fontSize: 18.0, color: enigmaWhite),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          // Button send message
          IconButton(
            icon: new Icon(Icons.send),
            onPressed: chatStatus == ChatStatus.blocked.index
                ? null
                : () => onSendMessage(textEditingController.text,
                    MessageType.text, DateTime.now().millisecondsSinceEpoch),
            color: enigmaWhite,
          ),
        ],
      ),
      width: double.infinity,
      height: 60.0,
      decoration: new BoxDecoration(
        border:
            new Border(top: new BorderSide(color: Colors.black, width: 0.5)),
        color: enigmaBlack,
      ),
    );
  }

  bool empty = true;

  loadMessagesAndListen() async {
    await Firestore.instance
        .collection(MESSAGES)
        .document(chatId)
        .collection(chatId)
        .orderBy(TIMESTAMP)
        .getDocuments()
        .then((docs) {
      if (docs.documents.isNotEmpty) empty = false;
      docs.documents.forEach((doc) {
        Map<String, dynamic> _doc = Map.from(doc.data);
        int ts = _doc[TIMESTAMP];
        _doc[CONTENT] = decryptWithCRC(_doc[CONTENT]);
        messages.add(Message(buildMessage(_doc),
            onDismiss: _doc[FROM] == peerNo ? () => deleteUpto(ts) : null,
            onTap: _doc[TYPE] == MessageType.image.index
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoViewWrapper(
                            tag: ts.toString(),
                            imageProvider:
                                CachedNetworkImageProvider(_doc[CONTENT]),
                          ),
                    ))
                : null, onDoubleTap: () {
          save(_doc);
        }, onLongPress: () {
          contextMenu(_doc);
        }, from: _doc[FROM], timestamp: ts));
      });
      if (mounted) {
        setState(() {
          messages = List.from(messages);
        });
      }
      msgSubscription = Firestore.instance
          .collection(MESSAGES)
          .document(chatId)
          .collection(chatId)
          .where(FROM, isEqualTo: peerNo)
          .snapshots()
          .listen((query) {
        if (empty == true ||
            query.documents.length != query.documentChanges.length) {
          query.documentChanges.where((doc) {
            return doc.oldIndex <= doc.newIndex;
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.document.data);
            int ts = _doc[TIMESTAMP];
            _doc[CONTENT] = decryptWithCRC(_doc[CONTENT]);
            messages.add(Message(buildMessage(_doc),
                onLongPress: () {
                  contextMenu(_doc);
                },
                onTap: _doc[TYPE] == MessageType.image.index
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoViewWrapper(
                                tag: ts.toString(),
                                imageProvider:
                                    CachedNetworkImageProvider(_doc[CONTENT]),
                              ),
                        ))
                    : null,
                onDoubleTap: () {
                  save(_doc);
                },
                from: _doc[FROM],
                timestamp: ts,
                onDismiss: () => deleteUpto(ts)));
          });
          if (mounted) {
            setState(() {
              messages = List.from(messages);
            });
          }
        }
      });
    });
  }

  void loadSavedMessages() {
    if (_savedMessageDocs.isEmpty) {
      Save.getSavedMessages(peerNo).then((_msgDocs) {
        if (_msgDocs != null) {
          setState(() {
            _savedMessageDocs = _msgDocs;
          });
        }
      });
    }
  }

  List<Widget> sortAndGroupSavedMessages(List<Map<String, dynamic>> _msgs) {
    _msgs.sort((a, b) => a[TIMESTAMP] - b[TIMESTAMP]);
    List<Message> _savedMessages = new List<Message>();
    List<Widget> _groupedSavedMessages = new List<Widget>();
    _msgs.forEach((msg) {
      _savedMessages.add(Message(
          buildMessage(msg, saved: true, savedMsgs: _savedMessages),
          saved: true,
          from: msg[FROM],
          onDoubleTap: () {}, onLongPress: () {
        contextMenu(msg, saved: true);
      },
          onDismiss: null,
          onTap: msg[TYPE] == MessageType.image.index
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoViewWrapper(
                          tag: "saved_" + msg[TIMESTAMP].toString(),
                          imageProvider: msg[CONTENT].toString().startsWith(
                                  'http') // See if it is an online or saved
                              ? CachedNetworkImageProvider(msg[CONTENT])
                              : Save.getImageFromBase64(msg[CONTENT]).image,
                        ),
                  ))
              : null,
          timestamp: msg[TIMESTAMP]));
    });

    _groupedSavedMessages
        .add(Center(child: Chip(label: Text('Saved Conversations'))));

    groupBy<Message, String>(_savedMessages, (msg) {
      return getWhen(DateTime.fromMillisecondsSinceEpoch(msg.timestamp));
    }).forEach((when, _actualMessages) {
      _groupedSavedMessages.add(Center(
          child: Chip(
        label: Text(when),
      )));
      _actualMessages.forEach((msg) {
        _groupedSavedMessages.add(msg.child);
      });
    });
    return _groupedSavedMessages;
  }

  List<Widget> getGroupedMessages() {
    List<Widget> _groupedMessages = new List<Widget>();
    int count = 0;
    groupBy<Message, String>(messages, (msg) {
      return getWhen(DateTime.fromMillisecondsSinceEpoch(msg.timestamp));
    }).forEach((when, _actualMessages) {
      _groupedMessages.add(Center(
          child: Chip(
        label: Text(when),
      )));
      _actualMessages.forEach((msg) {
        count++;
        if (unread != 0 && (messages.length - count) == unread - 1) {
          _groupedMessages.add(Center(
              child: Chip(
            label: Text('${unread} unread messages'),
          )));
          unread = 0; // reset
        }
        _groupedMessages.add(msg.child);
      });
    });
    return _groupedMessages.reversed.toList();
  }

  Widget buildSavedMessages() {
    return Flexible(
        child: ListView(
      padding: EdgeInsets.all(10.0),
      children: _savedMessageDocs.isEmpty
          ? [
              Padding(
                  padding: EdgeInsets.only(top: 200.0),
                  child: Text('No saved messages.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: enigmaWhite, fontSize: 18)))
            ]
          : sortAndGroupSavedMessages(_savedMessageDocs),
      controller: saved,
    ));
  }

  Widget buildMessages() {
    if (chatStatus == ChatStatus.blocked.index) {
      return AlertDialog(
        backgroundColor: Colors.black12,
        elevation: 10.0,
        title: Text(
          'Unblock ${peer[NICKNAME]}?',
          style: TextStyle(color: enigmaWhite),
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text('Unblock'),
              onPressed: () {
                ChatController.accept(currentUserNo, peerNo);
                setState(() {
                  chatStatus = ChatStatus.accepted.index;
                });
              })
        ],
      );
    }
    return Flexible(
        child: chatId == '' || messages.isEmpty || sharedSecret == null
            ? ListView(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 200.0),
                      child: Text(
                          sharedSecret == null
                              ? 'Setting things up.'
                              : 'Say Hi!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: enigmaWhite, fontSize: 18))),
                ],
                controller: realtime,
              )
            : ListView(
                padding: EdgeInsets.all(10.0),
                children: getGroupedMessages(),
                controller: realtime,
                reverse: true,
              ));
  }

  getWhen(date) {
    DateTime now = DateTime.now();
    String when;
    if (date.day == now.day)
      when = 'today';
    else if (date.day == now.subtract(Duration(days: 1)).day)
      when = 'yesterday';
    else
      when = DateFormat.MMMd().format(date);
    return when;
  }

  getPeerStatus(val) {
    if (val is bool && val == true) {
      return 'online';
    } else if (val is int) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
      String at = DateFormat.jm().format(date), when = getWhen(date);
      return 'last seen $when at $at';
    } else if (val is String) {
      if (val == currentUserNo) return 'typing…';
      return 'online';
    }
    return 'loading…';
  }

  bool isBlocked() {
    return chatStatus == ChatStatus.blocked.index ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Enigma.getNTPWrappedWidget(WillPopScope(
        onWillPop: () async {
          setLastSeen();
          if (lastSeen == peerNo)
            await Firestore.instance
                .collection(USERS)
                .document(currentUserNo)
                .setData({LAST_SEEN: true}, merge: true);
          return Future.value(true);
        },
        child: ScopedModel<DataModel>(
            model: _cachedModel,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, _model) {
              _cachedModel = _model;
              updateLocalUserData(_model);
              return peer != null
                  ? Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      child: Scaffold(
                          key: _scaffold,
                          backgroundColor: enigmaBlack,
                          appBar: PreferredSize(
                            preferredSize: Size.fromHeight(40.0),
                            child: Material(
                              child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (context, a1, a2) =>
                                                ProfileView(peer)));
                                  },
                                  dense: true,
                                  leading: Enigma.avatar(peer),
                                  title: Text(
                                    Enigma.getNickname(peer),
                                    style: TextStyle(
                                        color: enigmaWhite,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Theme(
                                      data: EnigmaTheme,
                                      child: PopupMenuButton(
                                        onSelected: (val) {
                                          switch (val) {
                                            case 'hide':
                                              ChatController.hideChat(
                                                  currentUserNo, peerNo);
                                              break;
                                            case 'unhide':
                                              ChatController.unhideChat(
                                                  currentUserNo, peerNo);
                                              break;
                                            case 'lock':
                                              ChatController.lockChat(
                                                  currentUserNo, peerNo);
                                              break;
                                            case 'unlock':
                                              ChatController.unlockChat(
                                                  currentUserNo, peerNo);
                                              break;
                                            case 'block':
                                              ChatController.block(
                                                  currentUserNo, peerNo);
                                              break;
                                            case 'unblock':
                                              ChatController.accept(
                                                  currentUserNo, peerNo);
                                              Enigma.toast('Unblocked.');
                                              break;
                                            case 'tutorial':
                                              Enigma.toast(
                                                  'Drag your friend\'s message from left to right to end conversations up until that message.');
                                              Future.delayed(
                                                      Duration(seconds: 2))
                                                  .then((_) {
                                                Enigma.toast(
                                                    'Swipe left on the screen to view saved messages.');
                                              });
                                              break;
                                            case 'remove_wallpaper':
                                              _cachedModel
                                                  .removeWallpaper(peerNo);
                                              Enigma.toast(
                                                  'Wallpaper removed.');
                                              break;
                                            case 'set_wallpaper':
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          HybridImagePicker(
                                                            title:
                                                                'Pick an image',
                                                            callback:
                                                                getWallpaper,
                                                          )));
                                              break;
                                          }
                                        },
                                        itemBuilder: (context) =>
                                            <PopupMenuItem<String>>[
                                              PopupMenuItem<String>(
                                                value:
                                                    hidden ? 'unhide' : 'hide',
                                                child: Text(
                                                  '${hidden ? 'Unhide' : 'Hide'} Chat',
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value:
                                                    locked ? 'unlock' : 'lock',
                                                child: Text(
                                                    '${locked ? 'Unlock' : 'Lock'} Chat'),
                                              ),
                                              PopupMenuItem<String>(
                                                value: isBlocked()
                                                    ? 'unblock'
                                                    : 'block',
                                                child: Text(
                                                    '${isBlocked() ? 'Unblock' : 'Block'} Chat'),
                                              ),
                                              PopupMenuItem<String>(
                                                  value: 'set_wallpaper',
                                                  child: Text('Set Wallpaper')),
                                              peer[WALLPAPER] != null
                                                  ? PopupMenuItem<String>(
                                                      value: 'remove_wallpaper',
                                                      child: Text(
                                                          'Remove Wallpaper'))
                                                  : null,
                                              PopupMenuItem<String>(
                                                child: Text('Show Tutorial'),
                                                value: 'tutorial',
                                              )
                                            ].where((o) => o != null).toList(),
                                      )),
                                  subtitle: chatId.isNotEmpty
                                      ? Text(
                                          getPeerStatus(peer[LAST_SEEN]),
                                          style: TextStyle(color: enigmaWhite),
                                        )
                                      : Text('loading…',
                                          style:
                                              TextStyle(color: enigmaWhite))),
                              elevation: 4,
                              color: enigmaBlack,
                            ),
                          ),
                          body: Stack(
                            children: <Widget>[
                              new Container(
                                decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                      image: peer[WALLPAPER] == null
                                          ? AssetImage("assets/bg.png")
                                          : Image.file(File(peer[WALLPAPER]))
                                              .image,
                                      fit: BoxFit.cover),
                                ),
                              ),
                              PageView(
                                children: <Widget>[
                                  Column(
                                    children: [
                                      // List of messages
                                      buildMessages(),
                                      // Input content
                                      isBlocked() ? Container() : buildInput(),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      // List of saved messages
                                      buildSavedMessages()
                                    ],
                                  ),
                                ],
                              ),

                              // Loading
                              buildLoading()
                            ],
                          )))
                  : Container();
            }))));
  }
}
