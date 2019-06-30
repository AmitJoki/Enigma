import 'dart:io';
import 'dart:ui';

import 'package:Enigma/const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';

class Save {
  static final LocalStorage storage = new LocalStorage(SAVED);

  static Future<String> getBase64FromImage({String imageUrl, File file}) {
    Completer<String> complete = new Completer<String>();
    if (file == null) {
      DefaultCacheManager().getFile(imageUrl).listen((stream) {
        stream.file.readAsBytes().then((imageBytes) {
          complete.complete(base64Encode(imageBytes));
        });
      });
    } else {
      List<int> imageBytes = file.readAsBytesSync();
      complete.complete(base64Encode(imageBytes));
    }
    return complete.future;
  }

  static Image getImageFromBase64(String encoded) =>
      Image.memory(base64.decode(encoded));

  static saveMessage(String peerNo, Map<String, dynamic> doc) {
    storage.ready.then((ready) {
      if (ready) {
        List<Map<String, dynamic>> saved =
            storage.getItem(peerNo)?.cast<Map<String, dynamic>>() ?? List<Map<String, dynamic>>();
        if (!(saved.any((_doc) => _doc[TIMESTAMP] == doc[TIMESTAMP]))) {
          // Don't repeat the saved ones
          saved.add(doc);
          storage.setItem(peerNo, saved);
        }
      }
    });
  }

  static deleteMessage(String peerNo, Map<String, dynamic> doc) {
    storage.ready.then((ready) {
      if (ready) {
        List<Map<String, dynamic>> saved =
            storage.getItem(peerNo)?.cast<Map<String, dynamic>>() ??
                List<Map<String, dynamic>>();
        saved.removeWhere((_d) =>
            _d[TIMESTAMP] == doc[TIMESTAMP] && _d[CONTENT] == doc[CONTENT]);
        storage.setItem(peerNo, saved);
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getSavedMessages(String peerNo) {
    Completer<List<Map<String, dynamic>>> completer =
        new Completer<List<Map<String, dynamic>>>();
    storage.ready.then((ready) {
      if (ready) {
        completer
            .complete(storage.getItem(peerNo)?.cast<Map<String, dynamic>>());
      }
    });
    return completer.future;
  }

  static void saveToDisk(ImageProvider provider, String filename) async {
    Directory appDocDirectory = await getExternalStorageDirectory();
    Directory dir = Directory(appDocDirectory.path + '/Enigma/photos');
    filename = filename.replaceAll(RegExp(r'[^\d]'), '');
    save(Function callback) {
      dir.exists().then((res) {
        if (res) {
          callback(dir);
        } else {
          dir.create(recursive: true).then((_dir) {
            callback(_dir);
          });
        }
      });
    }

    if (provider is CachedNetworkImageProvider) {
      CachedNetworkImageProvider _cache = provider;
      DefaultCacheManager().getFile(_cache.url).listen((stream) {
        _save(Directory directory) {
          stream.file.readAsBytes().then((bytes) {
            String extension =
                lookupMimeType('', headerBytes: bytes).split('/')[1];
            File f = new File(join(directory.path, '$filename.$extension'));
            f.writeAsBytes(bytes);
          });
        }

        save(_save);
      });
    } else {
      MemoryImage image = provider;
      _save(Directory directory) {
        String extension =
            lookupMimeType('', headerBytes: image.bytes).split('/')[1];
        File f = new File(join(directory.path, '$filename.$extension'));
        f.writeAsBytes(image.bytes);
      }

      save(_save);
    }
  }
}
